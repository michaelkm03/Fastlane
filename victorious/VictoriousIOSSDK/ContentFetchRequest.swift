//
//  ContentFetchRequest.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentFetchRequest: RequestType {
    private let url: NSURL
    private let currentUserID: String
    private let contentID: String
    
    public init?(apiPath: APIPath, currentUserID: String, contentID: String) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%USER_ID%%"] = currentUserID
        apiPath.macroReplacements["%%CONTENT_ID%%"] = contentID
        
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.currentUserID = currentUserID
        self.contentID = contentID
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: url)
    }

    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Content {
        let json = responseJSON["payload"]
        guard let content = Content(json: json) else {
            throw ResponseParsingError()
        }
        return content
    }
}
