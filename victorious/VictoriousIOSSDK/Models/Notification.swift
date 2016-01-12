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
    
    public let notificationID: String
    public let subject: String
    public let user: User
    public let createdAt: NSDate
    public let body: String?
    public let deeplink: String?
    public let imageURL: String?
    public let isRead: Bool?
    public let type: String?
    public let updatedAt: NSDate?
    
    public init?(json: JSON) {
        
        let dateFormatter = NSDateFormatter(format: .Standard)
        
        guard let createdAt     = dateFormatter.dateFromString(json["created_at"].stringValue),
            let notificationID  = String(json["id"].intValue) ?? json["id"].string,
            let subject         = json["subject"].string,
            let user            = User(json: json["created_by"]) else {
                return nil
        }
        self.createdAt          = createdAt
        self.notificationID     = notificationID
        self.subject            = subject
        self.user               = user
        
        body                    = json["body"].string
        deeplink                = json["deeplink"].string
        imageURL                = json["creator_profile_image_url"].string
        isRead                  = Bool(json["is_read"].stringValue)
        type                    = json["type"].string
        updatedAt               = dateFormatter.dateFromString(json["updated_at"].stringValue)
    }
}
