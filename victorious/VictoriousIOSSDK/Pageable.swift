//
//  Pageable.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Defines an object as a specialized RequestType that that can initialize a copy
/// of itself that is configured to load the previous or next page(s) of the same endpoint.
public protocol Pageable: RequestType {
    
    /// A request that will load the previous page of data relative to the receiver
    /// or `nil` if the receiver represents the first page.
    ///
    /// - parameter request: A request to copy and configure for the previous page relative to it
    init?( previousFromSourceRequest request: Self )
    
    /// A request that will load the next page of data relative to the receiver
    /// or `nil` if the receiver represents the last page.
    ///
    /// - parameter request: A request to copy and configure for the next page relative to it
    init?( nextRequestFromRequest request: Self )
    
    typealias PaginatorType: Paginator
    
    var paginator: PaginatorType { get }
}

/// Defines an object as a specialized Pageable that returns a next page based
/// on the results of the last execution of a request, which is provided as
/// a required parameter in an alternate initializer.
public protocol ResultBasedPageable {
    
    /// A request that will load the next page of data relative to the receiver
    /// or `nil` if the receiver represents the last page.
    ///
    /// - parameter request: A request to copy and configure for the next page relative to it
    /// - parameter resultCount: The number of paginated results returned in the previous
    /// execution of the provided `request` parameter
    init?( nextRequestFromRequest request: Self, resultCount: Int )
}
