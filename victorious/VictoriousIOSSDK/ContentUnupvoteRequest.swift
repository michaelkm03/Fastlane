//
//  ContentUnupvoteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentUnupvoteRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: contentUnupvoteURL)
        request.HTTPMethod = "POST"
        return request
    }
    
    private let contentUnupvoteURL: NSURL
    
    public init?(contentID: Content.ID, apiPath: APIPath) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%CONTENT_ID%%"] = contentID
        
        guard let url = apiPath.url else {
            return nil
        }
        
        contentUnupvoteURL = url
    }
}
