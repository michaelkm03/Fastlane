//
//  VUser.swift
//  victorious
//
//  Created by Tian Lan on 5/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc(VUser)
class VUser: NSManagedObject, UserModel {
    @NSManaged var username: String?
    @NSManaged var isBlockedByMainUser: NSNumber?
    @NSManaged var isCreator: NSNumber?
    @NSManaged var isDirectMessagingDisabled: NSNumber?
    @NSManaged var isFollowedByMainUser: NSNumber?
    @NSManaged var level: NSNumber?
    @NSManaged var levelProgressPercentage: NSNumber?
    @NSManaged var levelProgressPoints: NSNumber?
    @NSManaged var tier: String?
    @NSManaged var location: String?
    @NSManaged var displayName: String?
    @NSManaged var numberOfFollowers: NSNumber?
    @NSManaged var numberOfFollowing: NSNumber?
    @NSManaged var v_likesGiven: NSNumber?
    @NSManaged var v_likesReceived: NSNumber?
    @NSManaged var remoteId: NSNumber
    @NSManaged var v_completedProfile: NSNumber?
    @NSManaged var tagline: String?
    @NSManaged var token: String?
    @NSManaged var childSequences: Set<NSObject>?
    @NSManaged var comments: Set<NSObject>?
    @NSManaged var conversations: NSOrderedSet?
    @NSManaged var followers: NSOrderedSet?
    @NSManaged var following: NSOrderedSet?
    @NSManaged var followedHashtags: NSOrderedSet?
    @NSManaged var messages: Set<NSObject>?
    @NSManaged var notifications: Set<NSObject>?
    @NSManaged var pollResults: Set<NSObject>?
    @NSManaged var recentSequences: NSOrderedSet?
    @NSManaged var previewAssets: Set<VImageAsset>?
    @NSManaged var repostedSequences: Set<NSObject>?
    @NSManaged var maxUploadDuration: NSNumber
    @NSManaged var loginType: NSNumber
    @NSManaged var notificationSettings: VNotificationSettings?
    @NSManaged var likedSequences: NSOrderedSet?
    @NSManaged var accountIdentifier: String?
    @NSManaged var isNewUser: NSNumber?
    @NSManaged var isVIPSubscriber: NSNumber?
    @NSManaged var achievementsUnlocked: AnyObject?
    @NSManaged var v_avatarBadgeType: String?
    @NSManaged var content: Set<NSObject>?
    
    // MARK: - UserModel
    
    var id: Int {
        return remoteId.integerValue
    }
    
    var completedProfile: Bool? {
        return v_completedProfile?.boolValue
    }
    
    var fanLoyalty: FanLoyalty? {
        guard
            let level = self.level?.integerValue,
            let progress = self.levelProgressPercentage?.integerValue
        else {
            return nil
        }
        
        let achievements = achievementsUnlocked as? [String] ?? []
        return FanLoyalty(level: level, progress: progress, points: levelProgressPoints?.integerValue, tier: self.tier, achievementsUnlocked: achievements)
    }
    
    var isBlockedByCurrentUser: Bool? {
        return isBlockedByMainUser?.boolValue
    }
    
    var accessLevel: User.AccessLevel {
        let isCreator = self.isCreator?.boolValue ?? false
        return isCreator ? .owner : .user
    }
    
    var isFollowedByCurrentUser: Bool? {
        return isFollowedByMainUser?.boolValue
    }
    
    var likesGiven: Int? {
        return v_likesGiven?.integerValue
    }
    
    var likesReceived: Int? {
        return v_likesReceived?.integerValue
    }
    
    var previewImages: [ImageAssetModel] {
        return previewAssets?.flatMap { $0 } ?? []
    }
    
    var avatarBadgeType: AvatarBadgeType? {
        if v_avatarBadgeType == AvatarBadgeType.verified.stringRepresentation {
            return .verified
        }
        
        return nil
    }
    
    var vipStatus: VIPStatus? {
        let isVIP = isVIPSubscriber?.boolValue ?? false
        return VIPStatus(isVIP: isVIP)
    }
}
