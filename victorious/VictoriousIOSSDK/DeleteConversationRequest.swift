//
//  ConversationDeleteRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct ConversationDeleteRequest: RequestType {
    public let conversationID: Int
    
    public init(conversationID: Int) {
        self.conversationID = conversationID
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/message/delete_conversation")!)
        request.vsdk_addURLEncodedFormPost(["conversation_id" : conversationID])
        
        return request
    }
}
