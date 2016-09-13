//
//  ContentUpvoteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentUpvoteRequest: RequestType {
    private let url: NSURL
    
    public init?(apiPath: APIPath, contentID: Content.ID) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%CONTENT_ID%%"] = contentID
        
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        return request
    }
}
