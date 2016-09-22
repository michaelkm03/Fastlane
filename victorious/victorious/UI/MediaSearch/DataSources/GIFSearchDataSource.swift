
//
//  GIFSearchDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class GIFSearchDataSource: PaginatedDataSource, MediaSearchDataSource {
    
    private(set) var options = MediaSearchOptions()
    
    override init() {
        options.showPreview = true
    }
	
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
    
    var title: String {
        return NSLocalizedString( "GIF Search", comment: "" )
    }
}
