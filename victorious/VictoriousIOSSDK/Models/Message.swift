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
    public let messageID: Int64
    public let sender: User
    public let text: String?
    public let isRead: Bool?
    public let postedAt: NSDate?
    public let thumbnailURL: NSURL?
    public let mediaURL: NSURL?
    public let mediaType: String?
    public let isGIFStyle: Bool?
    public let shouldAutoplay: Bool?
}

extension Message {
    public init?(json: JSON) {

        // Parse Required Fields
        if let messageIDString = json["message_id"].string,
           let messageIDNumber = Int64(messageIDString),
           let sender = User(json: json["sender_user"]) {
            self.messageID = messageIDNumber
            self.sender = sender
        } else {
            return nil
        }
        
        // Parse Optionsl Fields independently
        self.text = json["text"].string
        if let isReadNumber = json["is_read"].int {
            self.isRead = Bool(isReadNumber)
        } else {
            self.isRead = nil
        }
        
        // Use our standard dateformat for postedAt
        if let postedAtString = json["posted_at"].string {
            let dateFormatter = NSDateFormatter(format: DateFormat.Standard)
            let date = dateFormatter.dateFromString(postedAtString)
            self.postedAt = date
        } else {
            self.postedAt = nil
        }
        
        if let thumbnailString = json["thumbnail_url"].string {
            self.thumbnailURL = NSURL(string: thumbnailString)
        } else {
            self.thumbnailURL = nil
        }
        
        if let mediaString = json["media_url"].string {
            self.mediaURL = NSURL(string: mediaString)
        } else {
            self.mediaURL = nil
        }

        self.isGIFStyle = json["is_gif_style"].bool
        self.shouldAutoplay = json["should_autoplay"].bool
        self.mediaType = json["media_type"].string
    }
}
