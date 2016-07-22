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
    var email: String? { get }
    var name: String? { get }
    var completedProfile: Bool? { get }
    var location: String? { get }
    var tagline: String? { get }
    var fanLoyalty: FanLoyalty? { get }
    var isBlockedByCurrentUser: Bool? { get }
    var accessLevel: User.AccessLevel { get }
    var isFollowedByCurrentUser: Bool? { get }
    var likesGiven: Int? { get }
    var likesReceived: Int? { get }
    var previewImages: [ImageAssetModel] { get }
    var avatarBadgeType: AvatarBadgeType? { get }
    var vipStatus: VIPStatus? { get }
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
    
    public let id: ID
    public let email: String?
    public let name: String?
    public let completedProfile: Bool?
    public let location: String?
    public let tagline: String?
    public let fanLoyalty: FanLoyalty?
    public let isBlockedByCurrentUser: Bool?
    public let accessLevel: AccessLevel
    public let isDirectMessagingDisabled: Bool?
    public let isFollowedByCurrentUser: Bool?
    public let numberOfFollowers: Int?
    public let numberOfFollowing: Int?
    public let likesGiven: Int?
    public let likesReceived: Int?
    public let previewImages: [ImageAssetModel]
    public let maxVideoUploadDuration: Int?
    public let avatarBadgeType: AvatarBadgeType?
    public let vipStatus: VIPStatus?
    
    // NOTE: If you add a parameter here, be sure to add it in any calls to this initializer that need to be
    // comprehensive.
    public init(
        id: Int,
        email: String? = nil,
        name: String? = nil,
        completedProfile: Bool? = nil,
        location: String? = nil,
        tagline: String? = nil,
        fanLoyalty: FanLoyalty? = nil,
        isBlockedByCurrentUser: Bool? = nil,
        accessLevel: AccessLevel = .user,
        isDirectMessagingDisabled: Bool? = nil,
        isFollowedByCurrentUser: Bool? = nil,
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
}
