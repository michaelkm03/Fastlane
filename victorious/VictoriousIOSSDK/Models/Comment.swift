//
//  Comment.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Comment {
    
    private let dateFormatter: NSDateFormatter = {
        return NSDateFormatter(format: .Standard)
    }()

    public let remoteID: Int64
    public let displayOrder: Int?
    public let userID: Int64
    public let shouldAutoplay: Bool?
    public let user: User
    public let text: String?
    public let mediaType: MediaAttachmentType?
    public let mediaURL: NSURL?
    public let thumbnailURL: NSURL?
    public let flags: Int?
    public let postedAt: NSDate
}

extension Comment {
    
    public init?(json: JSON) {
        
        guard let remoteID = Int64(json["id"].stringValue),
            let userID = Int64(json["user_id"].stringValue),
            let user = User(json: json["user"]),
            let postedAt = dateFormatter.dateFromString(json["posted_at"].stringValue) else {
                return nil
        }
        
        self.remoteID = remoteID
        self.userID = userID
        self.user = user
        self.postedAt = postedAt
        
        displayOrder = json["display_order"].int
        shouldAutoplay = json["should_autoplay"].bool
        text = json["text"].string
        mediaType = MediaAttachmentType(rawValue: json["media_type"].stringValue)
        mediaURL = NSURL(string: json["media_url"].stringValue)
        thumbnailURL = NSURL(string: json["thumbnail_url"].stringValue)
        flags = Int(json["flags"].stringValue)
    }
}
