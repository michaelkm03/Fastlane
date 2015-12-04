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
    
    var nextPageRequest: Self? { get }
    
    var previousPageRequest: Self? { get }
    
    var paginator: PaginatorType { get }
    
    init( paginator: PaginatorType )
}


extension Pageable {
    
    public var paginator: PaginatorType { return StandardPaginator() }
    
    public var nextPageRequest: Self? {
        return nil
    }
    
    public var previousPageRequest: Self? {
        return nil
    }
}
