//
//  HashtagSearchRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct HashtagSearchRequest: RequestType {
    private let url: URL
    
    // param: - searchTerm must be a urlPathPart percent encoded string
    public init?(apiPath: APIPath, searchTerm: String) {
        let charSet = CharacterSet.vsdk_pathPartAllowedCharacterSet
        let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: charSet) ?? searchTerm
        var apiPath = apiPath
        apiPath.queryParameters = ["hashtag": escapedSearchTerm]
        
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    
    public func parseResponse(response: URLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Hashtag] {
        guard let hashtags = responseJSON["payload"]["hashtags"].array else {
            throw ResponseParsingError()
        }
        return hashtags.flatMap { Hashtag(json: $0) }
    }
}
