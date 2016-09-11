//
//  StickerSearchDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StickerSearchDataSource: PaginatedDataSource, MediaSearchDataSource {
    
    private(set) var options = MediaSearchOptions()
    
    override init() {
        options.searchEnabled = false
        options.showPreview = true
    }
    
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
    
    var title: String {
        return NSLocalizedString( "Sticker Search", comment: "" )
    }
}