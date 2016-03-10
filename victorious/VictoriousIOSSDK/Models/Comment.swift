//
//  Comment.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct Comment {
    
    public struct RealtimeAttachment {
        public let time: Double
        
        public init( time: Double ) {
            self.time = time
        }
    }
    
    public struct CreationParameters {
        public let text: String?
        public let sequenceID: String
        public let realtimeAttachment: RealtimeAttachment?
        public let mediaAttachment: MediaAttachment?
        public let replyToCommentID: Int?
        
        public init( text: String?, sequenceID: String, replyToCommentID: Int?, mediaAttachment: MediaAttachment?, realtimeAttachment: RealtimeAttachment? ) {
            self.text = text
            self.sequenceID = sequenceID
            self.replyToCommentID = replyToCommentID
            self.mediaAttachment = mediaAttachment
            self.realtimeAttachment = realtimeAttachment
        }
    }
    
    public let commentID: Int
    public let userID: Int
    public let sequenceID: String
    public let user: User
    public let postedAt: NSDate
    public let displayOrder: Int?
    public let text: String?
    public let mediaAttachment: MediaAttachment?
    public let flags: Int?
    public let realtime: Bool?
    public let dislikes: Int?
    public let likes: Int?
    public let parentID: Int?
}

extension Comment {
    public init?(json: JSON) {
        guard let commentID = Int(json["id"].stringValue),
            let sequenceID = json["sequence_id"].string,
            let userID = Int(json["user_id"].stringValue),
            let user = User(json: json["user"]),
            let postedAt = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["posted_at"].stringValue) else {
                return nil
        }
        self.sequenceID         = sequenceID
        self.commentID          = commentID
        self.userID             = userID
        self.user               = user
        self.postedAt           = postedAt
        
        self.mediaAttachment    = MediaAttachment(json: json)
        likes                   = json["likes"].int
        dislikes                = json["dislikes"].int
        realtime                = json["realtime"].boolValue
        parentID                = json["parent_id"].int
        displayOrder            = json["display_order"].int
        text                    = json["text"].string
        flags                   = Int(json["flags"].stringValue)
    }
}
