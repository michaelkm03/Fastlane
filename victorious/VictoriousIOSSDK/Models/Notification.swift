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
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    public let body: String?
    public let createdAt: NSDate
    public let deeplink: String?
    public let imageURL: String?
    public let isRead: Bool?
    public let type: String?
    public let updatedAt: NSDate?
    public let remoteID: Int64
    public let subject: String
    public let displayOrder: Int?
    public let user: User
    
    public init?(json: JSON) {
        
        guard let createdAtDateString = json["created_at"].string,
            let createdAtDate = dateFormatter.dateFromString(createdAtDateString),
            let notificationID = json["id"].int64,
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
        if let isReadString = json["is_read"].string {
            isRead = isReadString == "true" ? true : false
        } else {
            isRead = nil
        }
        type = json["type"].string
        updatedAt = dateFormatter.dateFromString(json["updated_at"].stringValue)
        displayOrder = json["display_order"].int
    }
}
