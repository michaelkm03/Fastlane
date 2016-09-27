//
//  ContentDeleteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public struct ContentDeleteRequest: RequestType {
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.vsdk_addURLEncodedFormPost(["sequence_id": contentID])
        return request
    }
    
    private let url: NSURL
    private let contentID: Content.ID
    
    public init?(apiPath: APIPath, contentID: Content.ID) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%CONTENT_ID%%"] = contentID
        
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.contentID = contentID
    }
}
