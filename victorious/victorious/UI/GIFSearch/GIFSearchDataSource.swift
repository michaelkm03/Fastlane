//
//  GIFSearchCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension NSIndexPath {
    
    func nextSection() -> Int {
        return self.section + 1
    }
    
    func nextSectionIndexPath() -> NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: self.section + 1 )
    }
}

/// Collection view data source that lods GIF search results from backend and creates
/// and populated data on cells to show in results collection view
class GIFSearchDataSource: NSObject {
    
    struct Section {
        let results: [GIFSearchResult]
        
        subscript( index: Int ) -> GIFSearchResult {
            return self.results[ index ]
        }
        
        var count: Int {
            return self.results.count
        }
    }
    
    private let kHeaderReuseIdentifier = "GIFSearchAttributionView"
    
    private var _sections = [Section]()
    var sections: [Section] {
        return _sections
    }
    
    func removeHighlightSection( forIndexPath indexPath: NSIndexPath ) {
        let resultToHighlight = _sections[ indexPath.section ][ indexPath.row ]
        let section = Section(results: [ resultToHighlight ] )
        _sections.removeAtIndex( indexPath.nextSection() )
    }
    
    func addHighlightSection( forIndexPath indexPath: NSIndexPath ) {
        let section = _sections[ indexPath.section ]
        let resultToHighlight = section[ indexPath.row ]
        let childSection = Section(results: [ resultToHighlight ] )
        _sections.insert( childSection, atIndex: indexPath.nextSection() )
    }
    
    private var _currentOperation: NSOperation?
    
    /// Fetches data from the server and repopulates its backing model collection
    /// parameter `searchTerm:` A string to be used for the GIF search on the server
    /// parameter `completion`: A closure to be call when the operation is complete
    func performSearch( searchText:String, completion: (()->())? ) {
        
        _currentOperation?.cancel()
        _currentOperation = VObjectManager.sharedManager().searchForGIF( [ searchText == "" ? "sponge" : searchText ],
            success: { (results) in
                
                self._sections = []
                for var i = 0; i < results.count-1; i+=2 {
                    self._sections.append( Section(results:[results[i], results[i+1]] ) )
                }
                completion?()
                
            }, failure: { (error) in
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
