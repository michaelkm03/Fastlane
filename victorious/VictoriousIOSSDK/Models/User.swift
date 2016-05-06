//
//  User.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/24/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

/// A struct representing a user's information
public struct User {
    
    public struct VIPStatus {
        public let isVIP: Bool
        public let subscribeDate: NSDate
        
        public init?(json: JSON) {
            guard let isVIP = json["is_vip"].bool,
                let subscribeDate = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["subscribe_date"].stringValue) else {
                    return nil
            }
            self.isVIP = isVIP
            self.subscribeDate = subscribeDate
        }
    }
    
    public enum AccessLevel {
        case owner, user
        
        public init?(json: JSON) {
            switch json.stringValue {
                case "API_OWNER": self = .owner
                case "API_USER": self = .user
                default: return nil
            }
        }
        
        public var isCreator: Bool {
            switch self {
                case .owner: return true
                case .user: return false
            }
        }
    }
    
    public let userID: Int
    public let email: String?
    public let name: String?
    public let completedProfile: Bool?
    public let location: String?
    public let tagline: String?
    public let fanLoyalty: FanLoyalty?
    public let isBlockedByMainUser: Bool?
    public let accessLevel: AccessLevel?
    public let isDirectMessagingDisabled: Bool?
    public let isFollowedByMainUser: Bool?
    public let numberOfFollowers: Int?
    public let numberOfFollowing: Int?
    public let likesGiven: Int?
    public let likesReceived: Int?
    public let profileImageURL: String?
    public let tokenUpdatedAt: NSDate?
    public let previewImageAssets: [ImageAsset]?
    public let maxVideoUploadDuration: Int?
    public let avatar: Avatar?
    public let vipStatus: VIPStatus?
}

extension User {
    public init?(json: JSON) {
        // Check for "id" as either a string or a number, because the back-end is inconsistent.
        guard let userID = Int(json["id"].stringValue) ?? json["id"].int else {
            return nil
        }
        
        self.userID               = userID
        avatar                    = Avatar(json: json["avatar"])
        email                     = json["email"].string
        name                      = json["name"].string
        completedProfile          = json["is_complete"].boolValue || json["status"].string == "complete"
        location                  = json["profile_location"].string
        tagline                   = json["profile_tagline"].string
        fanLoyalty                = FanLoyalty(json: json["fanloyalty"])
        isBlockedByMainUser       = json["is_blocked"].bool
        vipStatus                 = VIPStatus(json: json["vip"])
        accessLevel               = AccessLevel(json: json["access_level"])
        isDirectMessagingDisabled = json["is_direct_message_disabled"].bool
        isFollowedByMainUser      = json["am_following"].bool
        numberOfFollowers         = Int(json["number_of_followers"].stringValue)
        numberOfFollowing         = Int(json["number_of_following"].stringValue)
        likesGiven                = json["engagements"]["likes_given"].int
        likesReceived             = json["engagements"]["likes_received"].int
        profileImageURL           = json["profile_image"].string
        maxVideoUploadDuration    = Int(json["max_video_duration"].stringValue)
        tokenUpdatedAt            = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["token_updated_at"].stringValue)
        
        if let previewImageAssets = json["preview"]["assets"].array {
            self.previewImageAssets = previewImageAssets.flatMap { ImageAsset(json: $0) }
        } else {
            self.previewImageAssets = nil
        }
    }
}
