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
        options.showAttribution = true
        options.showPreview = true
    }
	
	func performSearch( searchTerm searchTerm: String?, pageType: VPageType, completion: (NSError?->())? ) {
		
		self.loadPage( pageType,
			createOperation: {
				return GIFSearchOperation(searchTerm: searchTerm)
			},
			completion:{ (operation, error) in
				completion?( error )
			}
		)
    }
    
    var title: String {
        return NSLocalizedString( "GIF Search", comment: "" )
    }
}
