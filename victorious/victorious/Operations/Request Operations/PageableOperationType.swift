//
//  PageableOperationType.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Defines an object that can return copies of itself configured for loading next
/// and previous pages of a Pageable request
protocol PageableOperationType : class {
    
    /// The type of Pageable request used by this operation
    typealias PaginatedRequestType: Pageable
    
    /// Required initializer that takes a Pageable request
    init( request: PaginatedRequestType )
    
    /// The current request used for this operation, required in order to get the next/prev requests
    /// from which to maket the next/prev operations.
    var request: PaginatedRequestType { get }
    
    /// Returns a copy of this operation configured for loading next page worth of data
    func next() -> Self?
    
    /// Returns a copy of this operation configured for loading previous page worth of data
    func prev() -> Self?
    
    /// Returns the appropriate operation according to the page type or nil if not available.
    /// Internally calls `prev()` or `next()`.
    func operation( forPageType pageType: VPageType ) -> Self?
}

extension PageableOperationType {
    
    func next() -> Self? {
        if let request = PaginatedRequestType(nextRequestFromRequest: self.request) {
            return self.dynamicType.init(request: request)
        }
        return nil
    }
    
    func prev() -> Self? {
        if let request = PaginatedRequestType(previousFromSourceRequest: self.request) {
            return self.dynamicType.init(request: request)
        }
        return nil
    }
    
    func operation( forPageType pageType: VPageType ) -> Self? {
        switch pageType {
        case .First:
            return nil
        case .Next:
            return self.next()
        case .Previous:
            return self.prev()
        }
    }
}