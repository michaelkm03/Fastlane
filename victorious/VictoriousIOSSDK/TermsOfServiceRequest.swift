//
//  TermsOfServiceRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

public struct TermsOfServiceRequest: RequestType {
    
    public init() {
        // Just to be public
    }
    
    public let publicBaseURL = NSURL(string: "http://www.victorious.com/")!
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/tos")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        guard let htmlPayload = responseJSON["payload"].dictionary,
              let htmlString = htmlPayload["html"]?.string else {
            throw ResponseParsingError()
        }
        return htmlString
    }
    
}
