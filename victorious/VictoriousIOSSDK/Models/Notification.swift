//
//  Notification.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// A class representing a notification
///
/// A struct would be preferred, but is currently not compatible with our legacy pagination system.
///
public class Notification {
    
    public let subject: String
    public let user: User
    public let body: String?
    public let createdAt: Date
    public let deeplink: String?
    public let imageURL: String?
    public let isRead: Bool?
    public let type: String?
    public let updatedAt: Date?
    
    public init?(json: JSON) {
        
        guard let createdAt     = DateFormatter.vsdk_defaultDateFormatter().date(from:json["created_at"].stringValue),
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
        updatedAt               = DateFormatter.vsdk_defaultDateFormatter().date(from: json["updated_at"].stringValue)
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
