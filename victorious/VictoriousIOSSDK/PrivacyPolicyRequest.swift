//
//  PrivacyPolicyRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

public struct PrivacyPolicyRequest: RequestType {
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/static/privacy")!)
    }
    
    public func parseHTML(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData) throws -> String {
        guard let htmlString = String(data: responseData, encoding: NSUTF8StringEncoding) else {
                throw ResponseParsingError()
        }
        return htmlString
    }
    
    public func execute(baseURL baseURL: NSURL, requestContext: RequestContext, authenticationContext: AuthenticationContext?, callback: ( result: String?, error: ErrorType? ) -> ()) -> Cancelable {
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
        
        let dataTask = urlSession.dataTaskWithRequest(mutableRequest) { (data: NSData?, response: NSURLResponse?, requestError: NSError?) in
            
            let result: String?
            let error: ErrorType?
            if let response = response,
                let data = data {
                    do {
                        result = try self.parseHTML(response, toRequest: mutableRequest, responseData: data)
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
            
            callback(result: result, error: error)
        }
        dataTask.resume()
        return dataTask
    }
    
}