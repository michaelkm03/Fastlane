//
//  MediaSearchDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

struct MediaSearch {
	
	struct ReuseIdentifier {
		static let AttributionHeader = "MediaSearchAttributionView" ///< Set in storyboard
		static let ActivityFooter = "MediaSearchActivityFooter" ///< Set in storyboard
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
	
	enum State: Int {
		case None, Loading, Content, Error, NoResults
	}
	
	/// A type for organizing search results into grouped sections
	struct Section {
		
		/// The minimum amount of top and bottom space between a fullsize
		/// search result and the colleciton view bounds
		static let MinCollectionContainerMargin: CGFloat = 50.0
		
		let results: [MediaSearchResult]
		
		let isFullSize: Bool
		
		subscript( index: Int ) -> MediaSearchResult {
			return self.results[ index ]
		}
		
		var count: Int {
			return self.results.count
		}
	}
}

protocol MediaSearchDataSource: UICollectionViewDataSource {
	var sections: [MediaSearch.Section] { get }
	func performDefaultSearch( pageType: VPageType, completion: ((MediaSearch.ChangeResult?)->())? )
	func performSearchWithText( searchText: String, pageType: VPageType, completion: ((MediaSearch.ChangeResult?)->())? )
	func addHighlightSection( forIndexPath indexPath: NSIndexPath ) -> MediaSearch.ChangeResult
	func removeHighlightSection() -> MediaSearch.ChangeResult
	func clear() -> MediaSearch.ChangeResult
	var state: MediaSearch.State { get }
	var mostRecentSearchText: String? { get }
	var isLastPage: Bool { get }
}

class GIFSearchDataSource: NSObject, MediaSearchDataSource {
    
    private(set) var isLastPage: Bool = false
    private var mostRecentSearchOperation: GIFSearchOperation?
    private var mostRecentTrendingOperation: GIFSearchDefaultResultsOperation?
    
    private(set) var state = MediaSearch.State.None
    
	private(set) var sections: [MediaSearch.Section] = []
    private(set) var mostRecentSearchText: String?
    private var highlightedSection: (section: MediaSearch.Section, indexPath: NSIndexPath)?
	
    func performDefaultSearch( pageType: VPageType, completion: ((MediaSearch.ChangeResult?)->())? ) {
        
        // Only allow one next page load at a time
        if self.state == .Loading {
            completion?( nil )
            return
        }
        self.state = .Loading
        
        let nextOperation: GIFSearchDefaultResultsOperation?
        switch pageType {
        case .First:
            nextOperation = GIFSearchDefaultResultsOperation()
        case .Next:
            nextOperation = self.mostRecentTrendingOperation?.next()
        case .Previous:
            nextOperation = self.mostRecentTrendingOperation?.prev()
        }
        
        if let operation = nextOperation {
            self.mostRecentTrendingOperation = operation
            operation.queue() { operationError in
                self.mostRecentTrendingOperation = operation
                self.isLastPage = self.mostRecentTrendingOperation?.next() == nil
                
                // What we shall return to the view controller in order to 
                // indicate precisely what has changed
                var result = MediaSearch.ChangeResult()
                
                // Operation encountered an error
                if let error = operationError {
                    if self.isLastPage {
                        self.state = .Content
                    } else {
                        if pageType == .First {
                            self.clear()
                        }
                        self.state = .Error
                        result.error = error
                    }
                    
                // Operation successfully returned results
                } else if let results = operation.results as? [MediaSearchResult] {
                    self.state = .Content
                    result = self.updateDataSource( results, pageType: pageType )
                }
                
                completion?( result )
            }
        }
    }
    
    /// Fetches data from the server and repopulates its backing model collection
    func performSearchWithText( searchText: String, pageType: VPageType, completion: ((MediaSearch.ChangeResult?)->())? ) {
        
        // Only allow one next page load at a time
        if self.state == .Loading {
            completion?( nil )
            return
        }
        self.state = .Loading
        
        let nextOperation: GIFSearchOperation?
        switch pageType {
        case .First:
            nextOperation = GIFSearchOperation(searchTerm: searchText)
        case .Next:
            nextOperation = self.mostRecentSearchOperation?.next()
        case .Previous:
            nextOperation = self.mostRecentSearchOperation?.prev()
        }
        
        if let operation = nextOperation {
            self.mostRecentSearchOperation = operation
            
            operation.queue() { operationError in
                self.mostRecentSearchOperation = operation
                self.isLastPage = self.mostRecentSearchOperation?.next() == nil
                
                var result = MediaSearch.ChangeResult()
                if let error = operationError {
                    // Operation failed
                    if self.isLastPage {
                        self.state = .Content
                    }
                    else {
                        if pageType == .First {
                            self.clear()
                        }
                        self.state = .Error
                        result.error = error
                    }
                    
                // Operation successfully returned results
                } else if let results = operation.results as? [MediaSearchResult] {
                    self.state = .Content
                    self.mostRecentSearchText = searchText
                    result = self.updateDataSource( results, pageType: pageType )
                }
                completion?(result)
            }
        }
    }

    /// Clears the backing model, highlighted section and cancels any in-progress search operation
    func clear() -> MediaSearch.ChangeResult {
        var result = MediaSearch.ChangeResult()
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
    func removeHighlightSection() -> MediaSearch.ChangeResult {
        var result = MediaSearch.ChangeResult()
        if let highlightedSection = self.highlightedSection {
            let sectionIndex = highlightedSection.indexPath.section
            self.sections.removeAtIndex( sectionIndex )
            self.highlightedSection = nil
            result.deletedSections = NSIndexSet(index: sectionIndex)
            
        }
        return result
    }
    
    /// Adds a section beneath that shows the fullsize
    /// asset for the item at the index path.
    func addHighlightSection( forIndexPath indexPath: NSIndexPath ) -> MediaSearch.ChangeResult {
        var result = self.removeHighlightSection()
        
        let targetIndexPath: NSIndexPath = {
            if let deletedSection = result.deletedSections?.indexGreaterThanIndex(0) where deletedSection < indexPath.nextSection() {
                return indexPath.previousSectionIndexPath()
            }
            return indexPath
        }()
        
        let resultToHighlight = self.sections[ targetIndexPath.section ][ targetIndexPath.row ]
        let section = MediaSearch.Section(results: [ resultToHighlight ], isFullSize: true )
        self.sections.insert( section, atIndex: targetIndexPath.nextSection() )
        self.highlightedSection = (section, targetIndexPath.nextSectionIndexPath())
        
        result.insertedSections = NSIndexSet(index: targetIndexPath.nextSection())
        return result
    }
    
    // MARK: - Private
    
    private func updateDataSource( results: [MediaSearchResult], pageType: VPageType ) -> MediaSearch.ChangeResult {
        var result = MediaSearch.ChangeResult()
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
            let resultsForSection: [MediaSearchResult] = {
                if i + 1 < results.count {
                    return [results[i], results[i+1]]
                }
                else {
                    return [results[i]]
                }
            }()
            
            let section = MediaSearch.Section( results:resultsForSection, isFullSize: false )
            self.sections.append( section )
        }
        let range = NSRange( location: prevSectionCount, length: self.sections.count - prevSectionCount )
        result.insertedSections = NSIndexSet(indexesInRange: range)
        return result
    }
}

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
