//
//  TrendingHashtagsRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct TrendingHashtagsRequest: RequestType {
    private let url: URL
    
    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> [Hashtag] {
        guard let hashtagJSON = responseJSON["payload"]["hashtags"].array else {
            throw ResponseParsingError()
        }
        return hashtagJSON.flatMap { Hashtag(json: $0) }
    }
}
