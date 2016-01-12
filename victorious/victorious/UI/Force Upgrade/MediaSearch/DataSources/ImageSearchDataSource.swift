//
//  ImageSearchDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ImageSearchDataSource: PaginatedDataSource, MediaSearchDataSource {
	
	let defaultSearchTerm: String
	
	required init(defaultSearchTerm: String) {
		self.defaultSearchTerm = defaultSearchTerm
	}
	
	// MARK: - MediaSearchDataSource
	
	func performSearch( searchTerm searchTerm: String?, pageType: VPageType, completion: (NSError?->())? ) {
		
		let actualSearchTerm: String
		if let searchTerm = searchTerm {
			actualSearchTerm = searchTerm
		} else {
			actualSearchTerm = defaultSearchTerm
		}
		
		self.loadPage( pageType,
			createOperation: {
				return ImageSearchOperation(searchTerm: actualSearchTerm)
			},
			completion:{ (operation, error) in
				completion?( error )
			}
		)
	}
}
