//
//  PrivacyPolicyRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

public struct PrivacyPolicyRequest: RequestType {
    
    public init() {}
    
    public let publicBaseURL = NSURL(string: "http://www.victorious.com/")!
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/static/privacy")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        guard let htmlString = String(data: responseData, encoding: NSUTF8StringEncoding) else {
            throw ResponseParsingError()
        }
        return htmlString
    }
    
}
