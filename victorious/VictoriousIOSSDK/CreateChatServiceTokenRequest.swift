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

    private let userIDExpander = "%%USER_ID%%"
    
    private let currentUserId: Int
    private let url: NSURL

    public init?(expandableURLString: String, currentUserID: Int) {
        let expandedURLString = expandableURLString.stringByReplacingOccurrencesOfString(userIDExpander, withString: String(currentUserID))
        guard let url = NSURL(string: expandedURLString) else {
            return nil
        }
        
        self.url = url
        self.currentUserId = currentUserID
    }
    
    public var baseUrl: NSURL? {
        return url.baseURL
    }

    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        return request
    }

    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        guard let token = responseJSON["payload"]["token"].string ?? responseJSON["token"].string else {
            throw ResponseParsingError()
        }
        return token
    }
}
