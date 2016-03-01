//
//  RequestType.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/12/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

/// Represents an HTTP request to a Victorious server endpoint.
public protocol RequestType {
    /// The raw server response from this request will be parsed into an instance of this generic type.
    typealias ResultType
    
    /// An instance of NSURLRequest that will be used to send this request to the server
    var urlRequest: NSURLRequest { get }
    
    /// Translates the raw data response from the server into an instance of ResponseType
    ///
    /// - parameter response: Details about the server's response
    /// - parameter request: The NSURLRequest that was sent to the server
    /// - parameter responseData: The raw data returned by the server
    /// - parameter responseJSON: A JSON object parsed from responseData, if available
    func parseResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON ) throws -> ResultType
}

/// For RequestType implementations that have no results, this extension provides a default implementation of
/// parseResponse that does nothing. Useful for "fire and forget" API calls like tracking pings.
extension RequestType {
    public func parseResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON ) throws {
        // This method intentionally left blank.
    }
}

/// An asynchronous task that can be canceled
@objc(VSDKCancelable)
public protocol Cancelable: class {
    func cancel() -> ()
}

extension NSURLSessionTask: Cancelable {
}

extension RequestType {
    /// A closure to be called when the request finishes executing.
    ///
    /// - parameter result: The results of this request, if available.
    /// - parameter error: If an error occurred while executing this request, this parameter will have details.
    public typealias ResultCallback = ( result: ResultType?, error: ErrorType? ) -> ()
    
    /// Executes this request
    ///
    /// - returns: A Cancelable reference that can be used to cancel the network request before it completes
    public func execute(baseURL baseURL: NSURL, requestContext: RequestContext, authenticationContext: AuthenticationContext?, callback: ResultCallback? = nil) -> Cancelable {
        let urlSession = NSURLSession.sharedSession()
        let mutableRequest = urlRequest.mutableCopy() as! NSMutableURLRequest
        
        if let requestURLString = mutableRequest.URL?.absoluteString {
            mutableRequest.URL = NSURL(string: requestURLString, relativeToURL: baseURL)
        }
        if let authenticationContext = authenticationContext {
            mutableRequest.vsdk_setAuthorizationHeader(requestContext: requestContext, authenticationContext: authenticationContext)
        } else {
            mutableRequest.vsdk_setAuthorizationHeader(requestContext: requestContext)
        }
#if os(iOS)
        mutableRequest.vsdk_setOSVersionHeader()
#endif
        mutableRequest.vsdk_setPlatformHeader()
        mutableRequest.vsdk_setAppVersionHeaderValue(requestContext.appVersion)
        mutableRequest.vsdk_setIdentiferForVendorHeader(firstInstallDeviceID: requestContext.firstInstallDeviceID)
        
        if let sessionID = requestContext.sessionID {
            mutableRequest.vsdk_setSessionIDHeaderValue(sessionID)
        }
        if !requestContext.experimentIDs.isEmpty {
            let experiments = requestContext.experimentIDs.map { String($0) }.joinWithSeparator( "," )
            mutableRequest.vsdk_setExperimentsHeaderValue(experiments)
        }
        
        let dataTask = urlSession.dataTaskWithRequest(mutableRequest) { (data: NSData?, response: NSURLResponse?, requestError: NSError?) in
            
            let result: ResultType?
            let error: ErrorType?
            if let response = response,
               let data = data {
                do {
                    let responseJSON = JSON(data: data)
                    try self.parseError(responseJSON)
                    result = try self.parseResponse(response, toRequest: mutableRequest, responseData: data, responseJSON: responseJSON)
                    error = requestError
                }
                catch let e {
                    result = nil
                    error = e
                }
            }
            else {
                result = nil
                error = requestError
            }
            
            callback?(result: result, error: error)
        }
        dataTask.resume()
        return dataTask
    }
    
    private func parseError( responseJSON: JSON ) throws {
        if let errorCode = responseJSON["error"].int where errorCode != 0  {
            throw APIError(localizedDescription: responseJSON["message"].stringValue, code: errorCode)
        }
    }
}
