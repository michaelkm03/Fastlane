//
//  Notification.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A struct representing a notification
public struct Notification {
    
    public let body: String?
    public let createdAt: NSDate
    public let deeplink: String?
    public let imageURL: String?
    public let isRead: Bool?
    public let type: String?
    public let updatedAt: NSDate?
    public let remoteID: Int
    public let subject: String
    public let displayOrder: Int?
    public let user: User
    
    public init?(json: JSON) {
        
        guard let createdAtDateString = json["created_at"].string,
            let createdAtDate = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(createdAtDateString),
            let notificationID = json["id"].int,
            let subjectString = json["subject"].string,
            let sender = User(json: json["created_by"]) else {
                return nil
        }
        
        createdAt = createdAtDate
        remoteID = notificationID
        subject = subjectString
        user = sender
        body = json["body"].string
        deeplink = json["deeplink"].string
        imageURL = json["creator_profile_image_url"].string
        isRead = Bool(json["is_read"].stringValue)
        type = json["type"].string
        updatedAt = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["updated_at"].stringValue)
        displayOrder = json["display_order"].int
    }
}
