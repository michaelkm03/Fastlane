//
//  TutorialContentsRequest.swift
//  victorious
//
//  Created by Tian Lan on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Netowrk request to fetch an array of content which will be displayed as tutorial messages
public struct TutorialContentsRequest: RequestType {
    private let url: NSURL
    
    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Content] {
        guard let json = responseJSON["payload"]["viewed_contents"].array else {
            throw ResponseParsingError()
        }
        
        return json.flatMap { Content(json: $0) }
    }
}
