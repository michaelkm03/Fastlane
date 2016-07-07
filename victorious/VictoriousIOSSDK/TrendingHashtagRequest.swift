//
//  TrendingHashtagRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct TrendingHashtagRequest: RequestType {
    private let url: NSURL
    
    public init(url: NSURL) {
        self.url = url
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL:url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Hashtag] {
        guard let hashtagJSON = responseJSON["payload"]["hashtags"].array else {
            throw ResponseParsingError()
        }
        return hashtagJSON.flatMap { Hashtag(json: $0) }
    }
}
