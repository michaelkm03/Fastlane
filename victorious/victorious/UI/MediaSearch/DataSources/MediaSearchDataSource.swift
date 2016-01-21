//
//  MediaSearchDataSource+Collection.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc protocol MediaSearchDataSource {
    
    var options: MediaSearchOptions { get }
	
	func performSearch( searchTerm searchTerm: String?, pageType: VPageType, completion: (NSError?->())? )
	
    var title: String { get }
    
    var visibleItems: NSOrderedSet { get }
    
    func unload()
    
    var delegate: PaginatedDataSourceDelegate? { set get }
}
