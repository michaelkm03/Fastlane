//
//  DeleteRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// The type of content being flagged
/// Initialized with the content's identifier
public enum ContentDeleted {
    /// A sequence is being deleted. Endpoint is "/api/sequence/remove"
    case Sequence(sequenceID: Int64)
    /// A comment is being deleted. Endpoint is "/api/comment/remove"
    case Comment(commentID: Int64, removalReason: String)
    /// A conversation is being deleted. Endpoint is "/api/message/delete_conversation"
    case Conversation(conversationID: Int64)
}

public struct DeleteRequest: RequestType {
    public let targetContent: ContentDeleted
    
    public init(sequenceID: Int64) {
        targetContent = ContentDeleted.Sequence(sequenceID: sequenceID)
    }
    
    public init(commentID: Int64, removalReason: String = "") {
        targetContent = ContentDeleted.Comment(commentID: commentID, removalReason: removalReason)
    }
    
    public init(conversationID: Int64) {
        targetContent = ContentDeleted.Conversation(conversationID: conversationID)
    }
    
    public var urlRequest: NSURLRequest {
        var contentDeletedInfo: [String: Any]
        var urlString: String
        
        switch targetContent {
        case let .Sequence(sequenceID):
            urlString = "/api/sequence/remove"
            contentDeletedInfo = ["sequence_id": sequenceID]
        case let .Comment(commentID, removalReason):
            urlString = "/api/comment/remove"
            contentDeletedInfo = [
                "comment_id": commentID,
                "removal_reason": removalReason
            ]
        case let .Conversation(conversationID):
            urlString = "/api/message/delete_conversation"
            contentDeletedInfo = ["conversation_id": conversationID]
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.vsdk_addURLEncodedFormPost(contentDeletedInfo)
        
        return request
    }
}
