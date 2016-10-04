//
//  ContentUnupvoteRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentUnupvoteRequest: RequestType {
    private let url: URL
    
    public init?(apiPath: APIPath, contentID: Content.ID) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%CONTENT_ID%%"] = contentID
        
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws {
        // Protocol conformance
    }
}
