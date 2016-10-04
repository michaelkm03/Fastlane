//
//  Paginator.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that adds pagination arguments to a URL according to the
/// specifications of the intended endpoint.  Additionally, it instantiates copies
/// itself that are configured for next or previous pages, if available.
public protocol Paginator {
    
    /// Returns a Paginator object that contains data for retrieving the next page
    /// of paginated data after the receiver.
    func previousPage() -> Self?
    
    /// Returns a Paginator object that contains data for retrieving the next page
    /// of paginated data after the receiver.
    func nextPage( resultCount: Int ) -> Self?
    
    /// Modifies the provided request by adding pagination data to it according to
    /// the implementation-specific logic for doing so.
    func addPaginationArguments(to: inout URLRequest)
}

/// Defines are more domain-specific paginator that exposes its internal numeric
/// values that affect result size and offset
public protocol NumericPaginator: Paginator {
    var pageNumber: Int { get }
    var itemsPerPage: Int { get }
    var displayOrderCounterStart: Int { get }
    var displayOrderRangeStart: Int { get }
}

extension NumericPaginator {
    
    public var displayOrderCounterStart: Int {
        return (pageNumber - 1) * itemsPerPage
    }
    
    public var displayOrderRangeStart: Int {
        let start = (pageNumber - 1) * itemsPerPage
        if start > 0 {
            return start
        }
        return Int.min
    }
    
    public var displayOrderRangeEnd: Int {
        return max(displayOrderRangeStart, 0) + itemsPerPage
    }
}
