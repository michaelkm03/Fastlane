//
//  StickerTrayDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StickerTrayDataSource: PaginatedDataSource, UICollectionViewDataSource {
    func performSearch( searchTerm searchTerm: String?, pageType: VPageType, completion: (NSError? -> ())? ) {
        
        //TODO: REPLACE WITH REAL STICKER FETCH ENDPOINTS
        let searchOptions = GIFSearchOptions.Trending(url: "/api/image/trending_gifs")
        self.loadPage( pageType,
            createOperation: {
                return GIFSearchOperation(searchOptions: searchOptions)
            },
            completion:{ (results, error, cancelled) in
                completion?( error )
            }
        )
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError()
    }
}