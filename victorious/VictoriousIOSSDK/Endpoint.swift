//
//  Endpoint.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/21/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import SwiftyJSON

/// This protocol defines a type that can construct an HTTP request to a Victorious API endpoint and parse
/// the JSON response into strongly-typed model objects.
///
/// - Remark:
/// You may notice that this protocol is very similar to `Request`, in that they both define HTTP requests
/// and handle responses. The purpose of this protocol is specifically to implement a Victorious API, 
/// whereas `Request` implements any HTTP request to any remote API. The catch is that only `Request`
/// implementations can be `execute()`-ed.
///
/// `Endpoint` implementations cannot be executed by themselves because they are lacking some key functionality.
/// First of all, many `Endpoint` implentations do not contain absolute URLs, only a relative URL. Secondly, 
/// the Victorious API requires an Authorization header, and `Endpoint` instances do not have enough
/// information to calculate it.
///
/// In order to execute an instance of `Endpoint`, it must first be transformed into an instance of `Request`
/// by adding these key pieces of information. To do that, please see the `EndpointRequest` struct.
public protocol Endpoint {
    /// The raw server response from this endpoint will be parsed into an instance of this generic type.
    typealias ResultType
    
    /// An instance of NSURLRequest that will be used to send this request to the server.
    ///
    /// - Note:
    ///   The URL of this request does not need to be absolute. Relative URLs will be resolved against the baseURL
    ///   when this Endpoint becomes a Request
    var urlRequest: NSURLRequest { get }
    
    /// Translates raw data from the server into an instance of ResponseType
    ///
    /// - parameter request: The original NSURLRequest
    /// - parameter response: Details about the server's response
    /// - parameter responseData: The raw data returned by the server
    func parseResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON ) throws -> ResultType
}

/// For endpoints that have no results, provide a default implementation of parseResponse that does nothing.
/// Useful for "fire and forget" API calls like tracking pings, etc.
extension Endpoint {
    public func parseResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON ) throws {
        // This method intentionally left blank.
    }
}

/// ErrorType thrown when an endpoint request succeeds on an TCP/IP and HTTP level, but for some reason the response couldn't be parsed.
public struct EndpointResponseParsingError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    public let localizedDescription: String?
    
    public var description: String {
        return localizedDescription ?? "EndpointResponseParsingError"
    }
    
    public var debugDescription: String {
        return description
    }
    
    public init(localizedDescription: String? = nil) {
        self.localizedDescription = localizedDescription
    }
}

/// Transforms an instance of `Endpoint` into an instance of `Request` by adding information that
/// must be present on every Victorious API request. E.g. authentication token, app ID, etc.
public struct EndpointRequest<E: Endpoint>: Request {
    /// An absolute URL against which all relative Endpoint URLs will be resolved. E.g., if the baseURL is
    /// https://api.getvictorious.com and the Endpoint URL is /api/login, the URL for the request
    /// will be https://api.getvictorious.com/api/login.
    public let baseURL: NSURL
    
    /// Information required to calculate a valid Authorization header
    public let clientAuthorizationProvider: ClientAuthorizationProvider
    
    /// If necessary and available, the current user's account information
    public let userAuthorizationProvider: UserAuthorizationProvider?
    
    /// The server endpoint to which we are sending this request
    public let endpoint: E
    
    public init( baseURL: NSURL, endpoint: E, clientAuthorizationProvider: ClientAuthorizationProvider, userAuthorizationProvider: UserAuthorizationProvider? = nil ) {
        self.baseURL = baseURL
        self.endpoint = endpoint
        self.clientAuthorizationProvider = clientAuthorizationProvider
        self.userAuthorizationProvider = userAuthorizationProvider
    }
    
    public var urlRequest: NSURLRequest {
        let urlRequest = endpoint.urlRequest.mutableCopy() as! NSMutableURLRequest
        
        if let endpointURLString = urlRequest.URL?.absoluteString {
            urlRequest.URL = NSURL(string: endpointURLString, relativeToURL: baseURL)
        }
        if let userAuthorizationProvider = userAuthorizationProvider {
            urlRequest.vsdk_setAuthorizationHeader(clientAuthorizationProvider: clientAuthorizationProvider, userAuthorizationProvider: userAuthorizationProvider)
        } else {
            urlRequest.vsdk_setAuthorizationHeader(clientAuthorizationProvider: clientAuthorizationProvider)
        }
        return urlRequest
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData) throws -> E.ResultType {
        return try endpoint.parseResponse(response, toRequest: request, responseData: responseData, responseJSON: JSON(data: responseData) )
    }
}
