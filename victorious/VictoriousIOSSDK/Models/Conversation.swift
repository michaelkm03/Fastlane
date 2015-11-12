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
    public let conversationID: Int64
    public let previewMessageID: Int64
    public var isRead: Bool?
    public let recipient: User
    public let previewMessageText: String?
    public let postedAt: NSDate?
    public let thumbnailURL: NSURL?
    public let mediaURL: NSURL?
    public let mediaType: String?
}

extension Conversation {
    public init?(json: JSON) {
        if let conversationID = json["conversation_id"].int64,
            let messageIDString = json["message_id"].string,
            let messageIDNumber = Int64(messageIDString),
            let recipientUser = User(json:json["other_interlocutor_user"]),
            let postedAtString = json["posted_at"].string {
                self.conversationID = conversationID
                self.previewMessageID = messageIDNumber
                self.recipient = recipientUser

                let dateFormatter = NSDateFormatter(format: DateFormat.Standard)
                self.postedAt = dateFormatter.dateFromString(postedAtString)
        }
        else {
            return nil
        }
        
        self.previewMessageText = json["text"].string
        if let mediaURLString = json["media_url"].string {
            self.mediaURL = NSURL(string: mediaURLString)
        } else {
            self.mediaURL = nil
        }
        
        if let isReadNumber = json["is_read"].int {
            self.isRead = Bool(isReadNumber)
        } else {
            self.isRead = true
        }
        
        if let thumbnailURLString = json["thumbnail_url"].string {
            self.thumbnailURL = NSURL(string: thumbnailURLString)
        } else {
            self.thumbnailURL = nil
        }
        
        self.mediaType = json["media_type"].string
    }
}
