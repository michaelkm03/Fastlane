//
//  PaginatorType.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public protocol PaginatorType {
    
    var pageNumber: Int { get }
    
    var itemsPerPage: Int { get }
    
    /// Returns a PaginatorType object that contains data for retrieving the next page
    /// of paginated data after the receiver.
    func previousPage() -> PaginatorType?
    
    /// Returns a PaginatorType object that contains data for retrieving the next page
    /// of paginated data after the receiver.
    func nextPage( resultCount: Int ) -> PaginatorType?
    
    /// Modifies the provided request by adding pagination data to it according to
    /// the implementation-specific logic for doing so.
    func addPaginationArgumentsToRequest(request: NSMutableURLRequest)
}