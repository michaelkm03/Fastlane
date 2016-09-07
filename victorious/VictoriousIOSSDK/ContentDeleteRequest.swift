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
        let request = NSMutableURLRequest(URL: contentDeleteURL)
        request.HTTPMethod = "POST"
        request.vsdk_addURLEncodedFormPost(["sequence_id": contentID])
        return request
    }
    
    private let contentDeleteURL: NSURL
    private let contentID: Content.ID
    
    public init(contentID: Content.ID, apiPath: APIPath) {
        self.contentID = contentID
        
        var apiPath = apiPath
        apiPath.macroReplacements["%%CONTENT_ID%%"] = contentID
        
        contentDeleteURL = apiPath.url ?? NSURL()
    }
}
