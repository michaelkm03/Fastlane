//
//  Message.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Message {
    
    public struct CreationParameters {
        public let text: String
        public let recipientID: Int
        public let conversationID: Int
        public let mediaAttachment: MediaAttachment?
        
        public init(text: String, recipientID: Int, conversationID: Int, mediaAttachment: MediaAttachment?) {
            self.text = text
            self.recipientID = recipientID
            self.conversationID = conversationID
            self.mediaAttachment = mediaAttachment
        }
    }
    
    public let messageID: Int
    public let sender: User
    public let postedAt: NSDate
    public let isRead: Bool?
    public let text: String?
    public let mediaAttachment: MediaAttachment?
}

extension Message {
    
    public init?(json: JSON) {
        guard let messageID = Int(json["message_id"].stringValue),
            let sender = User(json: json["sender_user"]),
            let postedAt = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["posted_at"].stringValue) else {
            return nil
        }
        self.messageID          = messageID
        self.sender             = sender
        self.postedAt           = postedAt
        
        self.isRead             = json["is_read"].bool
        self.text               = json["text"].string
        self.mediaAttachment    = MediaAttachment(json: json)
    }
}
