//
//  MarkConversationReadRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct MarkConversationReadRequest : RequestType {

    public let conversationID: Int
    private static let basePath = NSURL(string: "/api/message/mark_conversation_read")!
    
    public init(conversationID: Int) {
        self.conversationID = conversationID
    }
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: MarkConversationReadRequest.basePath)
        urlRequest.vsdk_addURLEncodedFormPost(["conversation_id":String(conversationID)])
        return urlRequest
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Int? {
        let payload = responseJSON["payload"]
        return payload["unread_count"].int 
    }
}
