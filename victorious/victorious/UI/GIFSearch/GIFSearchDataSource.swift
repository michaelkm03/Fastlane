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
    
    // For organizing search results into grouped sections
    struct Section {
        
        // The minimum amount of top and bottom space between a fullsize
        // search result and the colleciton view bounds
        static let minMargin: CGFloat = 50.0
        
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
    
    private var _sections = [Section]()
    var sections: [Section] {
        return _sections
    }
    
    private var _highlightedSection: (section: Section, indexPath: NSIndexPath)?
    
    private var _currentOperation: NSOperation?
    
    // Removes the current full size asset section, wherever it may be
    // returns: whether or not the total section count was changed
    func removeHighlightSection() -> ChangeResult {
        var result = ChangeResult()
        if let highlightedSection = _highlightedSection {
            let sectionIndex = highlightedSection.indexPath.section
            _sections.removeAtIndex( highlightedSection.indexPath.section )
            _highlightedSection = nil
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
        
        let resultToHighlight = _sections[ targetIndexPath.section ][ targetIndexPath.row ]
        let section = Section(results: [ resultToHighlight ], isFullSize: true )
        _sections.insert( section, atIndex: targetIndexPath.nextSection() )
        _highlightedSection = (section, targetIndexPath.nextSectionIndexPath())
        
        result.insertedSection = targetIndexPath.nextSection()
        return result
    }
    
    /// Fetches data from the server and repopulates its backing model collection
    /// parameter `searchTerm:` A string to be used for the GIF search on the server
    /// parameter `completion`: A closure to be call when the operation is complete
    func performSearch( searchText:String, completion: (()->())? ) {
        
        _currentOperation?.cancel()
        _currentOperation = VObjectManager.sharedManager().searchForGIF( [ searchText == "" ? "sponge" : searchText ],
            success: { (results) in
                self._sections = []
                for var i = 0; i < results.count-1; i+=2 {
                    let results = [results[i], results[i+1]]
                    let section = Section( results:results, isFullSize: false )
                    self._sections.append( section )
                }
                completion?()
            },
            failure: { (error) in
                completion?()
            }
        )
    }
    
    /// Clears the backing model collection
    func clear() {
        _sections = []
    }
}

extension GIFSearchDataSource : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[ section ].count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let gifSearchResult = self.sections[ indexPath.section ][ indexPath.row ]
        
        let identifier = GIFSearchCell.suggestedReuseIdentifier
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( identifier, forIndexPath: indexPath ) as? GIFSearchCell {
            cell.assetUrl = NSURL(string: gifSearchResult.thumbnailStillUrl)
            cell.tintColor = UIColor.blueColor()
            cell.selected = NSSet(array: collectionView.indexPathsForSelectedItems() ).containsObject( indexPath )
            return cell
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
