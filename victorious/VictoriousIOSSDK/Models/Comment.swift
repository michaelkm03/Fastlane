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
    
    private let dateFormatter: NSDateFormatter = {
        return NSDateFormatter(format: .Standard)
    }()

    public let commentID: Int64
    public let displayOrder: Int?
    public let userID: Int64
    public let sequenceID: Int64
    public let shouldAutoplay: Bool?
    public let user: User
    public let text: String?
    public let mediaType: MediaAttachmentType?
    public let mediaURL: NSURL?
    public let thumbnailURL: NSURL?
    public let flags: Int?
    public let postedAt: NSDate
    
    public let mediaSize: CGSize
    public let realtime: Bool
    public let dislikes: Int64?
    public let likes: Int64?
    public let parentID: Int64?
}

extension Comment {
    
    public init?(json: JSON) {
        
        guard let commentID = Int64(json["id"].stringValue),
            let sequenceID = Int64(json["sequence_id"].stringValue),
            let userID = Int64(json["user_id"].stringValue),
            let user = User(json: json["user"]),
            let postedAt = dateFormatter.dateFromString(json["posted_at"].stringValue) else {
                return nil
        }
        
        self.sequenceID     = sequenceID
        self.commentID = commentID
        self.userID = userID
        self.user = user
        self.postedAt = postedAt
        
        mediaSize = CGSize(
            width: CGFloat(json["media_width"].floatValue),
            height: CGFloat(json["media_height"].floatValue)
        )
        
        likes           = json["likes"].int64
        dislikes        = json["dislikes"].int64
        realtime        = json["realtime"].boolValue
        parentID        = json["parent_id"].int64
        
        displayOrder    = json["display_order"].int
        shouldAutoplay  = json["should_autoplay"].bool
        text            = json["text"].string
        mediaType       = MediaAttachmentType(rawValue: json["media_type"].stringValue)
        mediaURL        = NSURL(string: json["media_url"].stringValue)
        thumbnailURL    = NSURL(string: json["thumbnail_url"].stringValue)
        flags           = Int(json["flags"].stringValue)
    }
}
