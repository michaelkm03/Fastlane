//
//  Paginated.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Defines an object that produces results which are populated in the `resultsArray`.
/// Any operations that don't need this abstract need not conform, for example if
/// they return only one result and the operation's API is consumed in a way where
/// abstract of type isn't necessary.
protocol ResultsOperation: class {
    
    /// A place to store the results so that they are available to calling code that is
    /// consuming this delegate (most likely an NSOperation).  This is why the protocol
    /// is required to be implemented by a class.
    var results: [AnyObject]? { set get }
}

protocol Paginated: ResultsOperation {
    
    /// The type of Paginator used by this operation
    associatedtype PaginatorType: Paginator
    
    /// The current paginator used for this operation, required in order to get
    /// the next/prev paginators from which to maket the next/prev operations.
    var paginator: PaginatorType { get }
    
    /// Returns a copy of this operation configured for loading next page worth of data
    func next() -> Self?
    
    /// Returns a copy of this operation configured for loading previous page worth of data
    func prev() -> Self?
}

protocol PaginatedOperation: Paginated {
    
    /// Required initializer that takes a value typed to PaginatorType
    init( operation: Self, paginator: PaginatorType )
}

extension Paginated where Self : PaginatedOperation {
    
    func prev() -> Self? {
        if let previousPaginator = self.paginator.previousPage() {
            return type(of: self).init(operation: self, paginator: previousPaginator)
        }
        return nil
    }
    
    func next() -> Self? {
        let results = self.results ?? []
        if let nextPaginator = self.paginator.nextPage( resultCount: results.count ) {
            return type(of: self).init(operation: self, paginator: nextPaginator)
        }
        return nil
    }
}

/// Defines an object that can return copies of itself configured for loading next
/// and previous pages of a Pageable request
protocol PaginatedRequestOperation: Paginated {

    /// The type of Pageable request used by this operation
    associatedtype PaginatedRequestType: Pageable
    
    /// The current request used for this operation, required in order to get the next/prev requests
    /// from which to maket the next/prev operations.
    var request: PaginatedRequestType { get }
    
    /// Required initializer that takes a value typed to PaginatedRequestType
    init( request: PaginatedRequestType )
}

extension Paginated where Self : PaginatedRequestOperation {
    
    var paginator: Self.PaginatedRequestType.PaginatorType {
        return request.paginator
    }
}

extension PaginatedRequestOperation {
    
    func prev() -> Self? {
        if let request = PaginatedRequestType(previousFromSourceRequest: self.request) {
            return type(of: self).init(request: request)
        }
        return nil
    }
}

extension PaginatedRequestOperation where PaginatedRequestType : ResultBasedPageable {
    
    func next() -> Self? {
        let results = self.results ?? []
        if let request = PaginatedRequestType(nextRequestFromRequest: self.request, resultCount: results.count) {
            return type(of: self).init(request: request)
        }
        return nil
    }
}
