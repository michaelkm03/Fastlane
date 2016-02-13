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
    
    public let subject: String
    public let user: User
    public let body: String?
    public let createdAt: NSDate
    public let deeplink: String?
    public let imageURL: String?
    public let isRead: Bool?
    public let type: String?
    public let updatedAt: NSDate?
    
    public init?(json: JSON) {
        
        guard let createdAt     = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["created_at"].stringValue),
            let subject         = json["subject"].string,
            let user            = User(json: json["created_by"]) else {
                return nil
        }
        self.createdAt          = createdAt
        self.subject            = subject
        self.user               = user
        
        body                    = json["body"].string
        deeplink                = json["deeplink"].string
        imageURL                = json["creator_profile_image_url"].string
        isRead                  = json["is_read"].v_boolFromAnyValue
        type                    = json["type"].string
        updatedAt               = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["updated_at"].stringValue)
    }
}

extension JSON {
    
    var v_stringFromInt: String? {
        if let integer = self.int {
            return String(integer)
        } else {
            return self.string
        }
    }
}
