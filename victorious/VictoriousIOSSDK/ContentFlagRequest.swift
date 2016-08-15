//
//  ContentFlagRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentFlagRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: contentFlagURL)
        request.HTTPMethod = "POST"
        return request
    }
    
    private let contentFlagURL: NSURL

    public init?(contentID: String, apiPath: APIPath) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%CONTENT_ID%%"] = contentID
        
        guard let url = apiPath.url else {
            return nil
        }
        
        contentFlagURL = url
    }
}
