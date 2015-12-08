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
    
    typealias PaginatorType: Paginator
    
    /// An abstract object that implements pagination logic and decorates URLs accordingly.
    var paginator: PaginatorType { get }
    
    /// Objects are required to support initialization with an existing paginator
    init( request: Self, paginator: PaginatorType  )
}

extension PaginatorPageable where Self : DynamicPageable {
    
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
