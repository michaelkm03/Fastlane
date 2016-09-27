//
//  MediaSearchDataSource+Collection.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc protocol MediaSearchDataSource: PaginatedDataSourceType {
    
    var options: MediaSearchOptions { get }
    
    var title: String { get }
	
	func performSearch( searchTerm: String?, pageType: VPageType, completion: ((NSError?) -> ())? )
}
