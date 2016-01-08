//
//  PaginatedOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol ResultsOperation : class {
    var results: [AnyObject]? { get }
    var didResetResults: Bool { get }
}

/// Defines an object that can return copies of itself configured for loading next
/// and previous pages of a Pageable request
protocol PaginatedOperation : ResultsOperation {

    /// The type of Pageable request used by this operation
    typealias PaginatedRequestType: Pageable
    
    /// The current request used for this operation, required in order to get the next/prev requests
    /// from which to maket the next/prev operations.
    var request: PaginatedRequestType { get }
    
    /// Required initializer that takes a value typed to PaginatedRequestType
    init( request: PaginatedRequestType )
    
    /// Returns a copy of this operation configured for loading next page worth of data
    func next() -> Self?
    
    /// Returns a copy of this operation configured for loading previous page worth of data
    func prev() -> Self?
}

extension PaginatedOperation {
    
    func prev() -> Self? {
        if let request = PaginatedRequestType(previousFromSourceRequest: self.request) {
            return self.dynamicType.init(request: request)
        }
        return nil
    }
}

extension PaginatedOperation where PaginatedRequestType : ResultBasedPageable {
    
    func next() -> Self? {
        guard let results = self.results else {
            fatalError( "The `resultCount` property has not been set on the receiver (\(self.dynamicType)).  This is required in order to determine if there is a next page available.  I would suggest setting it in the completion closure provided to `RequestOperation`s `requestExecutor.executeRequest(_:onComplete:onError:)` method." )
        }
        if let request = PaginatedRequestType(nextRequestFromRequest: self.request, resultCount: results.count) {
            return self.dynamicType.init(request: request)
        }
        return nil
    }
}