//
//  User.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/24/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

/// Conformers are models that store information about a user in the app
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
public protocol UserModel: PreviewImageContainer {
    var id: User.ID { get }
    var username: String? { get }
    var displayName: String? { get }
    var completedProfile: Bool? { get }
    var location: String? { get }
    var tagline: String? { get }
    var fanLoyalty: FanLoyalty? { get }
    var isRemotelyBlockedByCurrentUser: Bool? { get }
    var accessLevel: User.AccessLevel { get }
    var isRemotelyFollowedByCurrentUser: Bool? { get }
    var likesGiven: Int? { get }
    var likesReceived: Int? { get }
    var previewImages: [ImageAssetModel] { get }
    var avatarBadgeType: AvatarBadgeType? { get }
    var vipStatus: VIPStatus? { get }
}

public func ==(lhs: UserModel?, rhs: UserModel?) -> Bool {
    switch (lhs, rhs) {
        case (.None, .None):
            return true
        case (.Some(_), .None):
            return false
        case (.None, .Some(_)):
            return false
        case (.Some(let lhs), .Some(let rhs)):
            return lhs.id == rhs.id
                && lhs.username == rhs.username
                && lhs.displayName == rhs.displayName
                && lhs.location == rhs.location
                && lhs.tagline == rhs.tagline
                && lhs.likesGiven == rhs.likesGiven
                && lhs.likesReceived == rhs.likesReceived
                && lhs.fanLoyalty?.tier == rhs.fanLoyalty?.tier
                && lhs.accessLevel == rhs.accessLevel
                && lhs.vipStatus?.isVIP == rhs.vipStatus?.isVIP
                && lhs.avatarBadgeType == rhs.avatarBadgeType
    }
}

public func !=(lhs: UserModel?, rhs: UserModel?) -> Bool {
    return !(lhs == rhs)
}

/// A struct representing a user's information
public struct User: UserModel {
    public enum AccessLevel {
        case owner, user
        
        public init(json: JSON) {
            switch json.stringValue.lowercaseString {
                case "api_owner": self = .owner	
                case "api_user": self = .user
                default: self = .user
            }
        }
        
        public var isCreator: Bool {
            switch self {
                case .owner: return true
                case .user: return false
            }
        }
    }
    
    public typealias ID = Int
    
    public var id: ID
    public var username: String?
    public var displayName: String?
    public var completedProfile: Bool?
    public var location: String?
    public var tagline: String?
    public var fanLoyalty: FanLoyalty?
    public var isRemotelyBlockedByCurrentUser: Bool?
    public var accessLevel: AccessLevel
    public var isDirectMessagingDisabled: Bool?
    public var isRemotelyFollowedByCurrentUser: Bool?
    public var numberOfFollowers: Int?
    public var numberOfFollowing: Int?
    public var likesGiven: Int?
    public var likesReceived: Int?
    public var previewImages: [ImageAssetModel]
    public var maxVideoUploadDuration: Int?
    public var avatarBadgeType: AvatarBadgeType?
    public var vipStatus: VIPStatus?
    
    // NOTE: If you add a parameter here, be sure to add it in any calls to this initializer that need to be
    // comprehensive.
    public init(
        id: Int,
        username: String? = nil,
        displayName: String? = nil,
        completedProfile: Bool? = nil,
        location: String? = nil,
        tagline: String? = nil,
        fanLoyalty: FanLoyalty? = nil,
        isRemotelyBlockedByCurrentUser: Bool? = nil,
        accessLevel: AccessLevel = .user,
        isDirectMessagingDisabled: Bool? = nil,
        isRemotelyFollowedByCurrentUser: Bool? = nil,
        numberOfFollowers: Int? = nil,
        numberOfFollowing: Int? = nil,
        likesGiven: Int? = nil,
        likesReceived: Int? = nil,
        previewImages: [ImageAssetModel] = [],
        maxVideoUploadDuration: Int? = nil,
        avatarBadgeType: AvatarBadgeType? = nil,
        vipStatus: VIPStatus? = nil
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.completedProfile = completedProfile
        self.location = location
        self.tagline = tagline
        self.fanLoyalty = fanLoyalty
        self.isRemotelyBlockedByCurrentUser = isRemotelyBlockedByCurrentUser
        self.accessLevel = accessLevel
        self.isDirectMessagingDisabled = isDirectMessagingDisabled
        self.isRemotelyFollowedByCurrentUser = isRemotelyFollowedByCurrentUser
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
        username                  = json["username"].string
        displayName               = json["name"].string
        completedProfile          = json["is_complete"].boolValue || json["status"].string == "complete"
        location                  = json["profile_location"].string
        tagline                   = json["profile_tagline"].string
        fanLoyalty                = FanLoyalty(json: json["fanloyalty"])
        isRemotelyBlockedByCurrentUser    = json["is_blocked"].bool
        vipStatus                 = VIPStatus(json: json["vip"])
        accessLevel               = AccessLevel(json: json["access_level"])
        isDirectMessagingDisabled = json["is_direct_message_disabled"].bool
        isRemotelyFollowedByCurrentUser   = json["am_following"].bool
        numberOfFollowers         = Int(json["number_of_followers"].stringValue)
        numberOfFollowing         = Int(json["number_of_following"].stringValue)
        likesGiven                = json["engagements"]["likes_given"].int
        likesReceived             = json["engagements"]["likes_received"].int
        maxVideoUploadDuration    = Int(json["max_video_duration"].stringValue)
        
        let previewImages = json["preview"]["assets"].array ?? json["preview"]["media"]["assets"].arrayValue
        self.previewImages = previewImages.flatMap { ImageAsset(json: $0) }
    }
}

// MARK: - Upvote User

private var upvoteHistory: [User.ID: Bool] = [:]

extension UserModel {
    public func upvote() {
        upvoteHistory[id] = true
    }
    
    public func unUpvote() {
        upvoteHistory[id] = false
    }
    
    public var isUpvoted: Bool {
        if let record = upvoteHistory[id] {
            return record
        }
        else {
            return isRemotelyFollowedByCurrentUser ?? false
        }
    }
}

// MARK: - Block User

private var blockHistory: [User.ID: Bool] = [:]

extension UserModel {
    public func block() {
        blockHistory[id] = true
    }
    
    public func unblock() {
        blockHistory[id] = false
    }
    
    public var isBlocked: Bool {
        if let record = blockHistory[id] {
            return record
        }
        else {
            return isRemotelyBlockedByCurrentUser ?? false
        }
    }
}
