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
    
    /// An abstract object that implements pagination logic and decorates URLs accordingly.
    var paginator: Paginator { get }
    
    /// Objects are required to support initialization with an existing paginator
    init( request: Self, paginator: Paginator  )
    
    /// A request that will load the next page of data relative to the receiver
    /// or `nil` if the receiver represents the last page.
    init?( nextRequestFromRequest request: Self, resultCount: Int )
    
    /// A request that will load the previous page of data relative to the receiver
    /// or `nil` if the receiver represents the first page.
    init?( previousFromSourceRequest request: Self )
}

extension Pageable {
    
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
