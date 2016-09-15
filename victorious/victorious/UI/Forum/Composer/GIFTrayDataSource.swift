//
//  GIFTrayDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class GIFTrayDataSource: PaginatedDataSource, UICollectionViewDataSource {
    func performSearch( searchTerm searchTerm: String?, pageType: VPageType, completion: (NSError? -> ())? ) {
        
        let searchOptions: GIFSearchOptions
        if let searchTerm = searchTerm {
            searchOptions = GIFSearchOptions.Search(term: searchTerm, url: "/api/image/gif_search")
        } else {
            searchOptions = GIFSearchOptions.Trending(url: "/api/image/trending_gifs")
        }
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
