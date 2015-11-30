//
//  GIFSearchDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

/// Some convenience methods to easily get next/prev sections as Int or NSIndexPath.
private extension NSIndexPath {
    
    func nextSection() -> Int { return self.section + 1 }
    
    func nextSectionIndexPath() -> NSIndexPath {
        return NSIndexPath(forRow: self.row, inSection: self.nextSection() )
    }
    
    func previousSection() -> Int { return self.section - 1 }
    
    func previousSectionIndexPath() -> NSIndexPath {
        return NSIndexPath(forRow: self.row, inSection: self.previousSection() )
    }
}

/// Collection view data source that lods GIF search results from backend and creates
/// and populated data on cells to show in results collection view.
class GIFSearchDataSource: NSObject {
    
    private(set) var isLastPage: Bool = false
    enum State: Int {
        case None, Loading, Content, Error, NoResults
    }
    private(set) var state = State.None
    
    /// A type for organizing search results into grouped sections
    struct Section {
        
        /// The minimum amount of top and bottom space between a fullsize
        /// search result and the colleciton view bounds
        static let MinCollectionContainerMargin: CGFloat = 50.0
        
        let results: [GIFSearchResult]
        
        let isFullSize: Bool
        
        subscript( index: Int ) -> GIFSearchResult {
            return self.results[ index ]
        }
        
        var count: Int {
            return self.results.count
        }
    }
    
    /// A type used to record data source chanages that can then be applied to the collection
    /// view in a `performBatchUpdates(_:completion)` call.
    struct ChangeResult {
        var deletedSections: NSIndexSet?
        var insertedSections: NSIndexSet?
        var error: NSError?
        
        var hasChanges: Bool {
            return self.deletedSections?.count > 0 || self.insertedSections?.count > 0
        }
    }
    
    struct ReuseIdentifier {
        static let AttributionHeader = "GIFSearchAttributionView" ///< Set in storyboard
        static let ActivityFooter = "GIFSearchActivityFooter" ///< Set in storyboard
    }
    
    private(set) var sections = [Section]()
    private(set) var mostRecentSearchText: String?
    private var highlightedSection: (section: Section, indexPath: NSIndexPath)?
    
    func loadDefaultContent( pageType: VPageType, completion: ((ChangeResult?)->())? ) {
        
        // Only allow one next page load at a time
        if self.state == .Loading {
            completion?( nil )
            return
        }
        
        self.state = .Loading
        VObjectManager.sharedManager().loadTrendingGIFs( pageType,
            success: { (results, isLastPage) in
                self.state = .Content
                self.isLastPage = isLastPage
                let result = self.updateDataSource( results, pageType: pageType )
                completion?( result )
            },
            failure: { (error, isLastPage) in
                var result = ChangeResult()
                if isLastPage {
                    self.isLastPage = isLastPage
                    self.state = .Content
                }
                else {
                    if pageType == .First {
                        self.clear()
                    }
                    self.state = .Error
                    result.error = error
                }
                completion?( result )
            }
        )
    }
    
    /// Fetches data from the server and repopulates its backing model collection
    ///
    /// - parameter searchTerm: A string to be used for the GIF search on the server
    /// - parameter completion: A closure to be call when the operation is complete
    func performSearch( searchText:String, pageType: VPageType, completion: ((ChangeResult?)->())? ) {
        
        // Only allow one next page load at a time
        if self.state == .Loading {
            completion?( nil )
            return
        }
        
        self.state = .Loading
//        VObjectManager.sharedManager().searchForGIF( searchText,
//            pageType: pageType,
//            success: { (results, isLastPage) in
//                self.state = .Content
//                self.isLastPage = isLastPage
//                self.mostRecentSearchText = searchText
//                let result = self.updateDataSource( results, pageType: pageType )
//                completion?( result )
//            },
//            failure: { (error, isLastPage) in
//                var result = ChangeResult()
//                if isLastPage {
//                    self.isLastPage = isLastPage
//                    self.state = .Content
//                }
//                else {
//                    if pageType == .First {
//                        self.clear()
//                    }
//                    self.state = .Error
//                    result.error = error
//                }
//                completion?( result )
//            }
//        )
        
        let successClosure: ([GIFSearchResult]) -> Void = { results in
            self.state = .Content
            self.mostRecentSearchText = searchText
            let result = self.updateDataSource(results, pageType: pageType)
            completion?(result)
        }
        
        let failClosure: (NSError) -> Void = { error in
            var result = ChangeResult()
            self.state = .Error
            result.error = error
            completion?(result)
        }
        
        searchForGIF(searchText, onSuccess: successClosure, onFail: failClosure)
    }
    
    /// Clears the backing model, highlighted section and cancels any in-progress search operation
    func clear() -> ChangeResult {
        var result = ChangeResult()
        self.mostRecentSearchText = nil
        self.highlightedSection = nil
        if self.sections.count > 0 {
            let range = NSRange( location: 0, length: self.sections.count )
            result.deletedSections = NSIndexSet(indexesInRange: range)
            result.insertedSections = NSIndexSet(index:0)
        }
        else {
            result.deletedSections = NSIndexSet(index:0)
            result.insertedSections = NSIndexSet(index:0)
        }
        self.sections = []
        return result
    }
    
    /// Removes the current full size asset section, wherever it may be.
    ///
    /// - returns: `ChangeResult` indicating whether or not the total section count was changed
    func removeHighlightSection() -> ChangeResult {
        var result = ChangeResult()
        if let highlightedSection = self.highlightedSection {
            let sectionIndex = highlightedSection.indexPath.section
            self.sections.removeAtIndex( sectionIndex )
            self.highlightedSection = nil
            result.deletedSections = NSIndexSet(index: sectionIndex)
            
        }
        return result
    }
    
    /// For the provided index path, adds a section beneath that shows the fullsize
    /// asset for the item at the index path.
    ///
    /// - returns: whether or not the total section count was changed
    func addHighlightSection( forIndexPath indexPath: NSIndexPath ) -> ChangeResult {
        var result = self.removeHighlightSection()
        
        let targetIndexPath: NSIndexPath = {
            if let deletedSection = result.deletedSections?.indexGreaterThanIndex(0) where deletedSection < indexPath.nextSection() {
                return indexPath.previousSectionIndexPath()
            }
            return indexPath
        }()
        
        let resultToHighlight = self.sections[ targetIndexPath.section ][ targetIndexPath.row ]
        let section = Section(results: [ resultToHighlight ], isFullSize: true )
        self.sections.insert( section, atIndex: targetIndexPath.nextSection() )
        self.highlightedSection = (section, targetIndexPath.nextSectionIndexPath())
        
        result.insertedSections = NSIndexSet(index: targetIndexPath.nextSection())
        return result
    }
    
    // MARK: - Private
    
    private func updateDataSource( results: [GIFSearchResult], pageType: VPageType ) -> ChangeResult {
        var result = ChangeResult()
        if pageType == .First {
            if self.sections.count == 0 && results.count > 0 {
                result.deletedSections = NSIndexSet(index: 0) // No content cell
            }
            else if self.sections.count > 0 && results.count == 0 {
                let range = NSRange( location: 0, length: self.sections.count )
                result.deletedSections = NSIndexSet(indexesInRange: range)
            }
            self.sections = []
        }
        let prevSectionCount = self.sections.count
        for var i = 0; i < results.count; i+=2 {
            let resultsForSection: [GIFSearchResult] = {
                if i + 1 < results.count {
                    return [results[i], results[i+1]]
                }
                else {
                    return [results[i]]
                }
            }()
            
            let section = Section( results:resultsForSection, isFullSize: false )
            self.sections.append( section )
        }
        let range = NSRange( location: prevSectionCount, length: self.sections.count - prevSectionCount )
        result.insertedSections = NSIndexSet(indexesInRange: range)
        return result
    }
}

extension GIFSearchDataSource {
    func searchForGIF(searchText: String, onSuccess: ([GIFSearchResult]) -> Void, onFail: (NSError) -> Void) {
        let operation = GIFSearchRequestOperation(searchText: searchText)
        operation.queue() { error in
            if let e = error {
                onFail(e)
            } else {
                onSuccess(operation.searchResults)
            }
        }
    }
}
