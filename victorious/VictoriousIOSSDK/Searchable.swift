//
//  Searchable.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines request object that uses a PaginatorType to perform a search using a search term string.
/// An extension provides default functionality to share between conforming objects.  In addition
/// to the required properties, conformers need only implement `init(searchTerm:paginator:)`.
public protocol Searchable: Pageable {
    
    var searchTerm: String { get }
    
    var paginator: PaginatorType { get }
    
    init(searchTerm: String, pageNumber: Int, itemsPerPage: Int)
    
    init(request: Self, paginator: PaginatorType)
    
    init(searchTerm: String, paginator: PaginatorType)
}

extension Searchable {
    
    public init(searchTerm: String, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        let paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
        self.init( searchTerm: searchTerm, paginator: paginator )
    }
    
    public init( request: Self, paginator: PaginatorType ) {
        self.init( searchTerm: request.searchTerm, paginator: request.paginator)
    }
}