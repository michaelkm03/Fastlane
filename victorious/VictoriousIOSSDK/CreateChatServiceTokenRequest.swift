//
//  CreateChatServiceTokenRequest.swift
//  victorious
//
//  Created by Sebastian Nystorm on 6/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Request for creating a new authentication token at the backend used 
/// to identify the client when a WebSocket connection opens.
public struct CreateChatServiceTokenRequest: RequestType {
    private let url: URL

    public init?(apiPath: APIPath, currentUserID: User.ID) {
        var apiPath = apiPath
        apiPath.macroReplacements["%%USER_ID%%"] = String(currentUserID)
        
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

    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> String {
        guard let token = responseJSON["payload"]["token"].string ?? responseJSON["token"].string else {
            throw ResponseParsingError()
        }
        return token
    }
}
