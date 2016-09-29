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
    
    public var urlRequest: URLRequest {
        return URLRequest(url: URL(string: "/api/tos")!)
    }
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> String {
        guard let htmlPayload = responseJSON["payload"].dictionary,
              let htmlString = htmlPayload["html"]?.string else {
            throw ResponseParsingError()
        }
        return htmlString
    }
    
}
