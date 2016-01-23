//
//  PaginatedOperation.swift
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
protocol ResultsOperation {
    
    /// A place to store the results so that they are available to calling code that is
    /// consuming this delegate (most likely an NSOperation).  This is why the protocol
    /// is required to be implemented by a class.
    var results: [AnyObject]? { set get }
}

/// Defines an object that can return copies of itself configured for loading next
/// and previous pages of a Pageable request
protocol PaginatedOperation: ResultsOperation {

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
        let results = self.results ?? []
        if let request = PaginatedRequestType(nextRequestFromRequest: self.request, resultCount: results.count) {
            return self.dynamicType.init(request: request)
        }
        return nil
    }
}
