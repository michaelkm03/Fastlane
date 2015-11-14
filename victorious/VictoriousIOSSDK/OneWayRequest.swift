//
//  OneWayRequest.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/21/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Provides an implementation of Request that is constructed with a
/// simple NSURL and doesn't deliver a response, for those "fire and
/// forget" calls.
public struct OneWayRequest: RequestType {
    public let urlRequest: NSURLRequest
    
    public init(url: NSURL) {
        urlRequest = NSURLRequest(URL: url)
    }
}

public struct LogoutRequest: RequestType {
    
    public init() {}
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/logout")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws {
        
    }
}