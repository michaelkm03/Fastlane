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
    typealias PageableResultType
    typealias Paginator: PaginatorType
    
    /// An instance of a PaginatorType that will handle pagination for this request
    var paginator: Paginator { get }
    
    /// When conforming to this protocol, implement this 
    /// property instead of `RequestType`'s `urlRequest`
    var pageableURLRequest: NSURLRequest { get }
    
    /// When conforming to this protocol, implement this function instead of
    /// `RequestType`'s `parseResponse(_:toRequest:responseData:responseJSON:)`
    func parsePageableResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON ) throws -> PageableResultType
}

/// All `Pageable` types--that is, `RequestType`s that support pagination--must specify an instance of
/// this protocol, `PaginatorType`, to handle the details of the pagination. Specifically, these types
/// are in charge of modifying a request to add pagination details and returning a "continuation" that
/// can be used to retrieve the next page (or the previous page), if available.
public protocol PaginatorType {
    /// A type that represents a "next page" or "previous page" value in a paginated request
    typealias ContinuationType
    
    /// Given an NSURLRequest, return a new NSURLRequest with pagination added
    func paginatedRequestWithRequest(request: NSURLRequest) -> NSURLRequest

    /// Given a server response, return up to two continuations that can be used
    /// to create requests for the next page or previous page, if available.
    func parsePageInformationFromResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) -> (nextPage: ContinuationType?, previousPage: ContinuationType?)
}

public struct PageableResponse<T, R> {
    public let nextPage: T?
    public let previousPage: T?
    public let response: R
    
    public init(nextPage: T?, previousPage: T?, response: R)
    {
        self.nextPage = nextPage
        self.previousPage = previousPage
        self.response = response
    }
}

extension Pageable {
    public var urlRequest: NSURLRequest {
        return paginator.paginatedRequestWithRequest(pageableURLRequest)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: PageableResultType, nextPage: Paginator.ContinuationType?, previousPage: Paginator.ContinuationType?) {
        let pagination = paginator.parsePageInformationFromResponse(response, toRequest: request, responseData: responseData, responseJSON: responseJSON)
        let results = try parsePageableResponse(response, toRequest: request, responseData: responseData, responseJSON: responseJSON)
        return (results, pagination.nextPage, pagination.previousPage)
    }
}
