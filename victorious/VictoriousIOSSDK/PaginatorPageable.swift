//
//  PaginatorPageable.swift
//  victorious
//
//  Created by Patrick Lynch on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines an object as a specialized Pageable that configures its pagination arguments
/// using a generic Paginator object.
public protocol PaginatorPageable: Pageable {
    
    associatedtype PaginatorType: Paginator
    
    /// An abstract object that implements pagination logic and decorates URLs accordingly.
    var paginator: PaginatorType { get }
    
    /// Objects are required to provide initialization from a request and a paginator
    /// in order to support the default implementation of `Pageable`, which when creating
    /// previous or next requests to follow an original request will call this initializer
    /// passing in the original request and the paginator that calculates appropriate pagination
    /// arguments.
    ///
    /// - parameter request: A request from which this initializer is essentially making
    /// copy, allow a new request to be created with the same values as the original with
    /// any appropriate modications for pagination purposes.
    /// - parameter paginator: A Paginator object used by this request to help with pagination
    /// configuring including mangaging page size and items per page.
    init?( request: Self, paginator: PaginatorType  )
}

extension PaginatorPageable where Self : ResultBasedPageable {
    
    public init?( nextRequestFromRequest request: Self ) {
        return nil
    }
    
    public init?( nextRequestFromRequest request: Self, resultCount: Int ) {
        if let paginator = request.paginator.nextPage( resultCount ) {
            self.init( request: request, paginator: paginator )
        } else {
            return nil
        }
    }
    
    public init?( previousFromSourceRequest request: Self ) {
        if let paginator = request.paginator.previousPage() {
            self.init( request: request, paginator: paginator )
        } else {
            return nil
        }
    }
}
