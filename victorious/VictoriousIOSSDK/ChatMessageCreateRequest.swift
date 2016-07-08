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
        let request = NSMutableURLRequest(URL: textCreationURL)
        request.vsdk_addURLEncodedFormPost(["content": text])
        return request
    }
    
    private let text: String
    private let textCreationURL: NSURL
    
    public init(textCreationURL: NSURL, text: String) {
        self.text = text
        self.textCreationURL = textCreationURL
    }
}
