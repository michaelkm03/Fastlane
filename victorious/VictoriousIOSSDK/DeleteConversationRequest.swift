//
//  DeleteConversationRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct DeleteConversationRequest: RequestType {
    public let conversationID: Int64
    
    public init(conversationID: Int64) {
        self.conversationID = conversationID
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/message/delete_conversation")!)
        request.vsdk_addURLEncodedFormPost(["conversation_id" : conversationID])
        
        return request
    }
}
