//
//  User.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/24/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

/// A struct representing a user's information
public struct User {
    
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
    
    public let id: Int
    public let email: String?
    public let name: String?
    public let completedProfile: Bool?
    public let location: String?
    public let tagline: String?
    public let fanLoyalty: FanLoyalty?
    public let isBlockedByCurrentUser: Bool?
    public let accessLevel: AccessLevel?
    public let isDirectMessagingDisabled: Bool?
    public let isFollowedByCurrentUser: Bool?
    public let numberOfFollowers: Int?
    public let numberOfFollowing: Int?
    public let likesGiven: Int?
    public let likesReceived: Int?
    public let previewImages: [ImageAsset]
    public let maxVideoUploadDuration: Int?
    public let avatarBadgeType: AvatarBadgeType
    public let vipStatus: VIPStatus?
    
    public init(
        id: Int,
        email: String? = nil,
        name: String? = nil,
        completedProfile: Bool? = nil,
        location: String? = nil,
        tagline: String? = nil,
        fanLoyalty: FanLoyalty? = nil,
        isBlockedByCurrentUser: Bool? = nil,
        accessLevel: AccessLevel? = nil,
        isDirectMessagingDisabled: Bool? = nil,
        isFollowedByCurrentUser: Bool? = nil,
        numberOfFollowers: Int? = nil,
        numberOfFollowing: Int? = nil,
        likesGiven: Int? = nil,
        likesReceived: Int? = nil,
        previewImages: [ImageAsset] = [],
        maxVideoUploadDuration: Int? = nil,
        avatarBadgeType: AvatarBadgeType = .None,
        vipStatus: VIPStatus? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.completedProfile = completedProfile
        self.location = location
        self.tagline = tagline
        self.fanLoyalty = fanLoyalty
        self.isBlockedByCurrentUser = isBlockedByCurrentUser
        self.accessLevel = accessLevel
        self.isDirectMessagingDisabled = isDirectMessagingDisabled
        self.isFollowedByCurrentUser = isFollowedByCurrentUser
        self.numberOfFollowers = numberOfFollowers
        self.numberOfFollowing = numberOfFollowing
        self.likesGiven = likesGiven
        self.likesReceived = likesReceived
        self.previewImages = previewImages
        self.maxVideoUploadDuration = maxVideoUploadDuration
        self.avatarBadgeType = avatarBadgeType
        self.vipStatus = vipStatus
    }
}

extension User {
    public init?(json: JSON) {
        // Check for "id" as either a string or a number, because the back-end is inconsistent.
        guard let id = Int(json["id"].stringValue) ?? json["id"].int else {
            return nil
        }
        
        self.id                   = id
        avatarBadgeType           = AvatarBadgeType(json: json)
        email                     = json["email"].string
        name                      = json["name"].string
        completedProfile          = json["is_complete"].boolValue || json["status"].string == "complete"
        location                  = json["profile_location"].string
        tagline                   = json["profile_tagline"].string
        fanLoyalty                = FanLoyalty(json: json["fanloyalty"])
        isBlockedByCurrentUser    = json["is_blocked"].bool
        vipStatus                 = VIPStatus(json: json["vip"])
        accessLevel               = AccessLevel(json: json["access_level"])
        isDirectMessagingDisabled = json["is_direct_message_disabled"].bool
        isFollowedByCurrentUser   = json["am_following"].bool
        numberOfFollowers         = Int(json["number_of_followers"].stringValue)
        numberOfFollowing         = Int(json["number_of_following"].stringValue)
        likesGiven                = json["engagements"]["likes_given"].int
        likesReceived             = json["engagements"]["likes_received"].int
        maxVideoUploadDuration    = Int(json["max_video_duration"].stringValue)
        
        let previewImages = json["preview"]["assets"].array ?? json["preview"]["media"]["assets"].arrayValue
        self.previewImages = previewImages.flatMap { ImageAsset(json: $0) }
    }
    
    // MARK: - DictionaryConvertible
    
    public func toDictionary() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["id"] = id
        dictionary["profile_url"] = previewImages.first?.mediaMetaData.url.absoluteString
        dictionary["name"] = name
        return dictionary
    }
}
