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
    public let messageID: Int
    public let sender: User
    public let isRead: Bool?
    public let text: String?
    public let postedAt: NSDate?
    public let thumbnailURL: NSURL?
    public let mediaURL: NSURL?
    public let mediaType: String?
    public let isGIFStyle: Bool?
    public let shouldAutoplay: Bool?
}

extension Message {
    static var dateFormatter = NSDateFormatter(format: DateFormat.Standard)
    
    public init?(json: JSON) {
        guard let messageID = Int(json["message_id"].stringValue),
            let sender = User(json: json["sender_user"]) else {
            return nil
        }
        self.messageID      = messageID
        self.sender         = sender
        
        self.isRead         = json["is_read"].bool
        self.postedAt       = Message.dateFormatter.dateFromString(json["posted_at"].stringValue)
        self.text           = json["text"].string
        self.isGIFStyle     = json["is_gif_style"].bool
        self.shouldAutoplay = json["should_autoplay"].bool
        self.mediaType      = json["media_type"].string
        self.thumbnailURL   = NSURL(vsdk_string: json["media_url"].string)
        self.mediaURL       = NSURL(vsdk_string: json["thumbnail_url"].string)
    }
}
