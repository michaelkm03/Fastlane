
//
//  GIFSearchDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class GIFSearchDataSource: PaginatedDataSource, MediaSearchDataSource {
    
    fileprivate(set) var options = MediaSearchOptions()
    
    override init() {
        options.showPreview = true
    }
	
	func performSearch( searchTerm: String?, pageType: VPageType, completion: ((NSError?) -> ())? ) {
		
        let searchOptions: AssetSearchOptions
        if let searchTerm = searchTerm {
            searchOptions = AssetSearchOptions.Search(term: searchTerm, url: "/api/image/gif_search")
        } else {
            searchOptions = AssetSearchOptions.Trending(url: "/api/image/trending_gifs")
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
