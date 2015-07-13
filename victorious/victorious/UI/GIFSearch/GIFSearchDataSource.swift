//
//  GIFSearchCell.swift
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
    
    private let kHeaderReuseIdentifier = "GIFSearchAttributionView"
    
    private var state: State = .Loading
    private(set) var sections = [Section]()
    private var mostRecentSearchTerm: String?
    private var highlightedSection: (section: Section, indexPath: NSIndexPath)?
    private var currentOperation: NSOperation?
    
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
    func performSearch( searchText:String, completion: (()->())? ) {
        
        self.state = .Loading
        self.currentOperation?.cancel()
        self.currentOperation = VObjectManager.sharedManager().searchForGIF( [ searchText == "" ? "sponge" : searchText ],
            success: { (results) in
                self.clear()
                self.mostRecentSearchTerm = searchText
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
                    self.clear()
                    self.state = .Error
                }
                completion?()
            }
        )
    }
    
    /// Clears the backing model, highlighted section and cancels any in-progress search operation
    func clear() {
        self.mostRecentSearchTerm = nil
        self.currentOperation?.cancel()
        self.highlightedSection = nil
        
        sections = []
    }
    
    var noContentCellText: String {
        switch self.state {
        case .Error:
            return "Error loading results. :("
        case .Content where self.sections.count == 0:
            if let searchText = self.mostRecentSearchTerm {
                return "No results for \"\(searchText)\" :("
            }
            else  {
                return "No results :("
            }
        default:
            return ""
        }
    }
}

extension GIFSearchDataSource : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections.count == 0 ? 1 : self.sections[ section ].count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.sections.count == 0 ? 1 : self.sections.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if self.sections.count == 0 {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( GIFSearchCellNoContent.suggestedReuseIdentifier, forIndexPath: indexPath ) as? GIFSearchCellNoContent {
                cell.text = self.noContentCellText
                return cell
            }
        }
        else {
            let section = self.sections[ indexPath.section ]
            let result = section.results[ indexPath.row ]
            if section.isFullSize {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( GIFSearchCellFullsize.suggestedReuseIdentifier, forIndexPath: indexPath ) as? GIFSearchCellFullsize {
                    cell.assetUrl = NSURL(string: result.mp4Url)
                    return cell
                }
            }
            else {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( GIFSearchCell.suggestedReuseIdentifier, forIndexPath: indexPath ) as? GIFSearchCell {
                    cell.assetUrl = NSURL(string: result.thumbnailStillUrl)
                    cell.selected = NSSet(array: collectionView.indexPathsForSelectedItems() ).containsObject( indexPath )
                    return cell
                }
            }
        }
        fatalError( "Could not find cell." )
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if let attributionView = collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderReuseIdentifier, forIndexPath: indexPath ) as? UICollectionReusableView {
            return attributionView
        }
        fatalError( "Could not find reuseable view." )
    }
}
