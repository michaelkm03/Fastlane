//
//  Pageable.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A special RequestType for endpoints that support pagination
public protocol Pageable: RequestType {
    
    /// A request that will load the next page of data relative to the receiver
    /// or `nil` if the receiver represents the last page.
    var nextPageRequest: Self? { get }
    
    /// A request that will load the previous page of data relative to the receiver
    /// or `nil` if the receiver represents the first page.
    var previousPageRequest: Self? { get }
    
    /// An abstract object that implements pagination logic and decorates URLs accordingly.
    var paginator: PaginatorType { get }
    
    /// Objects are required to support initialization with an existing paginator
    init( paginator: PaginatorType )
}

extension Pageable {
    
    /// Provides a default paginator for implementations that do no required custom pagination lgoic
    public var paginator: PaginatorType {
        return StandardPaginator()
    }
    
    public var nextPageRequest: Self? {
        if let nextPaginator = self.paginator.getNextPage( self.paginator.itemsPerPage ) {
            return self.dynamicType.init(paginator: nextPaginator)
        }
        return nil
    }
    
    public var previousPageRequest: Self? {
        if let previousPaginator = self.paginator.getPreviousPage() {
            return self.dynamicType.init(paginator: previousPaginator)
        }
        return nil
    }
}
