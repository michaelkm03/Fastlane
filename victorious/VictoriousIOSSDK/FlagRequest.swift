//
//  FlagRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// The type of content being flagged
/// Initialized with the content's identifier
public enum ContentFlagged {
    /// A sequence is being flagged. Endpoint is "/api/sequence/flag"
    case Sequence(sequenceID: Int64)
    /// A comment is being flagged. Endpoint is "/api/comment/flag"
    case Comment(commentID: Int64)
    /// A message is being flagged. Endpoint is "/api/message/flag"
    case Message(messageID: Int64)
}

public struct FlagRequest: RequestType {
    public let targetContent: ContentFlagged
    
    public init(sequenceID: Int64) {
        self.targetContent = ContentFlagged.Sequence(sequenceID: sequenceID)
    }
    
    public init(commentID: Int64) {
        self.targetContent = ContentFlagged.Comment(commentID: commentID)
    }
    
    public init (messageID: Int64) {
        self.targetContent = ContentFlagged.Message(messageID: messageID)
    }
    
    public var urlRequest: NSURLRequest {
        var contentFlaggedInfo: [String: Int64]
        var urlString: String
        switch targetContent {
        case let .Sequence(sequenceID):
            urlString = "/api/sequence/flag"
            contentFlaggedInfo = ["sequence_id": sequenceID]
        case let .Comment(commentID):
            urlString = "/api/comment/flag"
            contentFlaggedInfo = ["comment_id": commentID]
        case let .Message(messageID):
            urlString = "/api/message/flag"
            contentFlaggedInfo = ["message_id": messageID]
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.vsdk_addURLEncodedFormPost(contentFlaggedInfo)
        
        return request
    }
}
