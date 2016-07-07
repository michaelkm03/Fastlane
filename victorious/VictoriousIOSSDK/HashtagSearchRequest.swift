//
//  HashtagSearchRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct HashtagSearchRequest: RequestType {
    
    public let searchTerm: String
    
    let url: NSURL
    
    public init(request: HashtagSearchRequest) {
        self.searchTerm = request.searchTerm
        self.url = request.url
    }
    
    // param: - searchTerm must be a urlPathPart percent encoded string
    public init?(searchTerm: String, apiPath: APIPath) {
        let charSet = NSCharacterSet.vsdk_pathPartAllowedCharacterSet
        guard let escapedSearchTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(charSet) else {
            return nil
        }
        
        var apiPath = apiPath
        apiPath.queryParameters = ["hashtag" : escapedSearchTerm]
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.searchTerm = searchTerm
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: url)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Hashtag] {
        guard let hashtags = responseJSON["payload"]["hashtags"].array else {
            throw ResponseParsingError()
        }
        return hashtags.flatMap { Hashtag(json: $0) }
    }
}
