//
//  ConversationWithUserRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

// A request to the backend to determine whether or not the currently logged
// in user has an existing conversation with the passed in userID.
public struct ConversationWithUserRequest: RequestType {

    public let userID: Int
    private static let basePath = NSURL(string: "/api/message/conversation_with_user")!
    
    public init(userID: Int) {
        self.userID = userID
    }
    
    public var urlRequest: NSURLRequest {
        let path = ConversationWithUserRequest.basePath.URLByAppendingPathComponent(String(self.userID))
        let urlRequest = NSMutableURLRequest(URL: path)

        return urlRequest
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (conversationID: Int, messages: [Message]) {
        guard let messagesArrayJSON = responseJSON["payload"]["messages"].array,
              let conversationIDString = responseJSON["payload"]["conversation_id"].string,
              let conversationID = Int(conversationIDString) else {
            throw ResponseParsingError()
        }
        let messages = messagesArrayJSON.flatMap{ Message(json: $0) }
        
        return (conversationID, messages)
    }
}
