//
//  Request.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/12/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

/// This protocol defines a type that can construct an HTTP request and, once that request is sent to a server
/// (via the execute() extension function), parse the response into something more specialized than NSData.
///
/// - seealso: `Endpoint`
public protocol Request {
    /// The raw server response from this request will be parsed into an instance of this generic type.
    typealias ResultType
    
    /// An instance of NSURLRequest that will be used to send this request to the server
    var urlRequest: NSURLRequest { get }
    
    /// Translates raw data from the server into an instance of ResponseType
    ///
    /// - parameter request: The original NSURLRequest
    /// - parameter response: Details about the server's response
    /// - parameter responseData: The raw data returned by the server
    func parseResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData ) throws -> ResultType
}

/// For Request types that have no results, provide a default implementation of parseResponse that does nothing.
/// Useful for "fire and forget" API calls like tracking pings, etc.
extension Request {
    public func parseResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData ) throws {
        // This method intentionally left blank.
    }
}

/// An asynchronous task that can be canceled
public protocol CancelableTask {
    func cancel() -> ()
}

extension NSURLSessionTask: CancelableTask {
}

extension Request {
    /// A closure to be called when the request finishes executing.
    ///
    /// - parameter result: The results of this request, if available.
    /// - parameter error: If an error occurred while executing this request, this parameter will have details.
    public typealias ResultCallback = ( result: ResultType?, error: ErrorType? ) -> ()
    
    /// Executes this request
    ///
    /// - returns: A CancelableTask reference that can be used to cancel the network request before it completes
    public func execute(callback: ResultCallback? = nil) -> CancelableTask {
        let urlSession = NSURLSession.sharedSession()
        let request = urlRequest.copy() as! NSURLRequest
        let dataTask = urlSession.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, requestError: NSError?) in
            
            let result: ResultType?
            let error: ErrorType?
            if let response = response,
               let data = data {
                do {
                    result = try self.parseResponse(response, toRequest: request, responseData: data)
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
}
