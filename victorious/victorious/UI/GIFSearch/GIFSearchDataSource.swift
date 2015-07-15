//
//  GIFSearchDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

// Some convenience methods to easily get next/prev sections as Int or NSIndexPath
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
/// and populated data on cells to show in results collection view
class GIFSearchDataSource: NSObject {
    
    enum State: Int {
        case Loading, Content, Error
    }
    
    // For organizing search results into grouped sections
    struct Section {
        
        // The minimum amount of top and bottom space between a fullsize
        // search result and the colleciton view bounds
        static let kMinMargin: CGFloat = 50.0
        
        let results: [GIFSearchResult]
        
        let isFullSize: Bool
        
        subscript( index: Int ) -> GIFSearchResult {
            return self.results[ index ]
        }
        
        var count: Int {
            return self.results.count
        }
    }
    
    // For recording data source chanages that can then be applied to the collection
    // view in a `performBatchUpdates(_:completion)` call
    struct ChangeResult {
        var deletedSection: Int? = nil
        var insertedSection: Int? = nil
    }
    
    // Reuse identifiers for header and footer views (set in storyboard)
    static let kHeaderReuseIdentifier = "GIFSearchAttributionView"
    static let kFooterReuseIdentifier = "GIFSearchActivityFooter"
    
    private(set) var state: State = .Content
    private(set) var sections = [Section]()
    private(set) var mostRecentSearchText: String?
    private var highlightedSection: (section: Section, indexPath: NSIndexPath)?
    
    // Removes the current full size asset section, wherever it may be
    // returns: whether or not the total section count was changed
    func removeHighlightSection() -> ChangeResult {
        var result = ChangeResult()
        if let highlightedSection = self.highlightedSection {
            let sectionIndex = highlightedSection.indexPath.section
            self.sections.removeAtIndex( sectionIndex )
            self.highlightedSection = nil
            result.deletedSection = sectionIndex
        }
        return result
    }
    
    // For the provided index path, adds a section beneath that shows the fullsize
    // asset for the item at the index path
    // returns: whether or not the total section count was changed
    func addHighlightSection( forIndexPath indexPath: NSIndexPath ) -> ChangeResult {
        var result = self.removeHighlightSection()
        
        let targetIndexPath: NSIndexPath = {
            if let deletedSection = result.deletedSection where deletedSection < indexPath.nextSection() {
                return indexPath.previousSectionIndexPath()
            }
            return indexPath
        }()
        
        let resultToHighlight = self.sections[ targetIndexPath.section ][ targetIndexPath.row ]
        let section = Section(results: [ resultToHighlight ], isFullSize: true )
        self.sections.insert( section, atIndex: targetIndexPath.nextSection() )
        self.highlightedSection = (section, targetIndexPath.nextSectionIndexPath())
        
        result.insertedSection = targetIndexPath.nextSection()
        return result
    }
    
    /// Fetches data from the server and repopulates its backing model collection
    /// parameter `searchTerm:` A string to be used for the GIF search on the server
    /// parameter `completion`: A closure to be call when the operation is complete
    func performSearch( searchText:String, pageType: VPageType, completion: (()->())? ) {
        
        // Only allow one next page load at a time
        if self.state == .Loading {
            completion?()
            return
        }
        
        self.state = .Loading
        VObjectManager.sharedManager().searchForGIF( [ searchText == "" ? "sponge" : searchText ],
            pageType: pageType,
            success: { (results) in
                if pageType == .First {
                    self.sections = []
                }
                self.mostRecentSearchText = searchText
                self.state = .Content
                for var i = 0; i < results.count-1; i+=2 {
                    let results = [results[i], results[i+1]]
                    let section = Section( results:results, isFullSize: false )
                    self.sections.append( section )
                }
                completion?()
            },
            failure: { (error, cancelled: Bool) in
                if !cancelled {
                    if pageType == .First {
                        self.clear()
                    }
                    self.state = .Error
                }
                completion?()
            }
        )
    }
    
    /// Clears the backing model, highlighted section and cancels any in-progress search operation
    func clear() {
        self.mostRecentSearchText = nil
        self.highlightedSection = nil
        self.sections = []
    }
}
