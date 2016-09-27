//
//  TemplateRequest.swift
//  victorious
//
//  Created by Josh Hinman on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct TemplateRequest: RequestType {
    
    public init() { }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(url: NSURL(string: "/api/template")! as URL)
    }
    
    public func parseResponse(response: URLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> NSData {
        return responseData
    }
}
