//
//  ChatMessageCreateRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ChatMessageCreateRequest: RequestType {
    public var urlRequest: NSURLRequest {
        guard let url = apiPath.url else {
            assertionFailure("Failed to generate URL from API path for creating chat message.")
            return NSURLRequest()
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.vsdk_addURLEncodedFormPost(["content": text])
        return request
    }
    
    private let apiPath: APIPath
    private let text: String
    
    public init(apiPath: APIPath, text: String) {
        self.apiPath = apiPath
        self.text = text
    }
}
