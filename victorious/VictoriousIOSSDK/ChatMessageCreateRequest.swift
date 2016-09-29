//
//  ChatMessageCreateRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ChatMessageCreateRequest: RequestType {
    public var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.vsdk_addURLEncodedFormPost(["content": text])
        return request
    }
    
    private let url: URL
    private let text: String
    
    public init?(apiPath: APIPath, text: String) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
        self.text = text
    }
}
