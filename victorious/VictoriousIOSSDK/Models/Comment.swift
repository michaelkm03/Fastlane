//
//  Comment.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum MediaAttachmentType: String {
    case Image      = "image"
    case Video      = "video"
    case GIF        = "gif"
    case Ballistic  = "voteType"
}

public struct Comment {
    
    public struct Media {
        public let type: MediaAttachmentType
        public let url: NSURL
        public let size: CGSize
        public let thumbnailURL: NSURL
    }
    
    private let dateFormatter: NSDateFormatter = {
        return NSDateFormatter(format: .Standard)
    }()

    public let commentID: Int64
    public let displayOrder: Int?
    public let userID: Int64
    public let sequenceID: String
    public let shouldAutoplay: Bool?
    public let user: User
    public let text: String?
    public let media: Media?
    
    public let flags: Int?
    public let postedAt: NSDate
    public let realtime: Bool
    public let dislikes: Int64?
    public let likes: Int64?
    public let parentID: Int64?
}

extension Comment {
    
    public init?(json: JSON) {
        
        guard let commentID = Int64(json["id"].stringValue),
            let sequenceID = json["sequence_id"].string,
            let userID = Int64(json["user_id"].stringValue),
            let user = User(json: json["user"]),
            let postedAt = dateFormatter.dateFromString(json["posted_at"].stringValue) else {
                return nil
        }
        
        self.sequenceID = sequenceID
        self.commentID  = commentID
        self.userID     = userID
        self.user       = user
        self.postedAt   = postedAt
        
        if let mediaWidth = json["media_width"].float,
            let mediaHeight = json["media_height"].float,
            let mediaType = MediaAttachmentType(rawValue: json["media_type"].stringValue),
            let mediaURLString = json["media_url"].string,
            let mediaURL = NSURL(string:mediaURLString),
            let thumbnailURLString = json["thumbnail_url"].string,
            let thumbnailURL = NSURL(string: thumbnailURLString) {
                media = Comment.Media(
                    type: mediaType,
                    url: mediaURL,
                    size: CGSize(width: CGFloat(mediaWidth), height: CGFloat(mediaHeight)),
                    thumbnailURL: thumbnailURL
                )
        } else {
            media = nil
        }
        
        likes           = json["likes"].int64
        dislikes        = json["dislikes"].int64
        realtime        = json["realtime"].boolValue
        parentID        = json["parent_id"].int64
        
        displayOrder    = json["display_order"].int
        shouldAutoplay  = json["should_autoplay"].bool
        text            = json["text"].string
        flags           = Int(json["flags"].stringValue)
    }
}
