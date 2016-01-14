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

public struct MediaAttachment {
    public let type: MediaAttachmentType
    public let url: NSURL
    public let size: CGSize
    public let thumbnailURL: NSURL
}

public struct Comment {

    public let commentID: Int
    public let displayOrder: Int?
    public let userID: Int
    public let sequenceID: String
    public let shouldAutoplay: Bool?
    public let user: User
    public let text: String?
    public let media: MediaAttachment?
    
    public let flags: Int?
    public let postedAt: NSDate
    public let realtime: Bool
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
        
        self.sequenceID = sequenceID
        self.commentID  = commentID
        self.userID     = userID
        self.user       = user
        self.postedAt   = postedAt
        
        if let mediaWidth = json["media_width"].float,
            let mediaHeight = json["media_height"].float,
            let mediaType = MediaAttachmentType(rawValue: json["media_type"].stringValue),
            let mediaURL = NSURL(vsdk_string: json["media_url"].string),
            let thumbnailURL = NSURL(vsdk_string: json["thumbnail_url"].string) {
                media = MediaAttachment(
                    type: mediaType,
                    url: mediaURL,
                    size: CGSize(width: CGFloat(mediaWidth), height: CGFloat(mediaHeight)),
                    thumbnailURL: thumbnailURL
                )
        } else {
            media = nil
        }
        
        likes           = json["likes"].int
        dislikes        = json["dislikes"].int
        realtime        = json["realtime"].boolValue
        parentID        = json["parent_id"].int
        
        displayOrder    = json["display_order"].int
        shouldAutoplay  = json["should_autoplay"].bool
        text            = json["text"].string
        flags           = Int(json["flags"].stringValue)
    }
}
