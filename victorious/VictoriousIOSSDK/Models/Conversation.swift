//
//  Conversation.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Conversation {
    public let conversationID: Int
    public let previewMessageID: Int
    public var isRead: Bool?
    public let otherUser: User
    public let previewMessageText: String?
    public let postedAt: NSDate?
    public let thumbnailURL: NSURL?
    public let mediaURL: NSURL?
    public let mediaType: MediaAttachmentType?
}

extension Conversation {
    
    public init?(json: JSON) {
        guard let conversationID    = json["conversation_id"].int,
            let previewMessageID    = Int(json["message_id"].stringValue),
            let otherUser           = User(json:json["other_interlocutor_user"]),
            let postedAt            = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["posted_at"].stringValue) else {
            return nil
        }
        
        self.conversationID         = conversationID
        self.previewMessageID       = previewMessageID
        self.otherUser              = otherUser
        self.postedAt               = postedAt
                
        self.previewMessageText     = json["text"].string
        self.isRead                 = json["is_read"].bool
        self.mediaURL               = NSURL(vsdk_string: json["media_url"].string)
        self.thumbnailURL           = NSURL(vsdk_string: json["thumbnail_url"].string)
        
        self.mediaType = MediaAttachmentType(rawValue: json["media_type"].stringValue)
    }
}
