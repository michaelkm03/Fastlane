//
//  ContentUpvoteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentUpvoteRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: contentUpvoteURL)
        request.HTTPMethod = "POST"
        return request
    }
    
    private let contentUpvoteURL: NSURL
    
    public init(contentID: Content.ID, apiPath: APIPath) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%CONTENT_ID%%"] = contentID
        contentUpvoteURL = apiPath.url ?? NSURL()
    }
}
