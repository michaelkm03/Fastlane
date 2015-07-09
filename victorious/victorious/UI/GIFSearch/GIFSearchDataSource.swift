//
//  GIFSearchCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Cell to represent GIF search result in a collectin of search results
class GIFSearchCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    static var suggestedReuseIdentifier: String {
        return NSStringFromClass(self).pathExtension
    }
}

/// Collection view data source that lods GIF search results from backend and creates
/// and populated data on cells to show in results collection view
class GIFSearchDataSource: NSObject {
    
    private let kHeaderReuseIdentifier = "GIFSearchAttributionView"
    
    private var _results = [GIFSearchResult]()
    var results: [GIFSearchResult] {
        return _results
    }
    
    private var _currentOperation: NSOperation?
    
    /// Fetches data from the server and repopulates its backing model collection
    /// parameter `searchTerm:` A string to be used for the GIF search on the server
    /// parameter `completion`: A closure to be call when the operation is complete
    func performSearch( searchText:String, completion: (()->())? ) {
        
        _currentOperation?.cancel()
        _currentOperation = VObjectManager.sharedManager().searchForGIF( [ searchText ],
            success: { (results) in
                self._results = results
                completion?()
                
            }, failure: { (error) in
                completion?()
            }
        )
    }
    
    /// Clears the backing model collection
    func clear() {
        _results = []
    }
}

extension GIFSearchDataSource : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let gifSearchResult = self.results[ indexPath.row ]
        
        let identifier = GIFSearchCell.suggestedReuseIdentifier
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( identifier, forIndexPath: indexPath ) as? GIFSearchCell,
            let url = NSURL(string: gifSearchResult.thumbnailStillUrl) {
                
            cell.imageView.alpha = cell.imageView.image == nil ? 0.0 : 1.0
            cell.imageView.sd_setImageWithURL( url, completed: { (image, error, cacheType, url) -> Void in
                UIView.animateWithDuration( 0.5, animations: {
                    cell.imageView.alpha = 1.0
                })
            })
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
