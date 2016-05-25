//
//  VUser.swift
//  victorious
//
//  Created by Tian Lan on 5/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc(VUser)
class VUser: NSManagedObject {
    @NSManaged var email: String?
    @NSManaged var isBlockedByMainUser: NSNumber?
    @NSManaged var isCreator: NSNumber?
    @NSManaged var isDirectMessagingDisabled: NSNumber?
    @NSManaged var isFollowedByMainUser: NSNumber?
    @NSManaged var level: NSNumber?
    @NSManaged var levelProgressPercentage: NSNumber?
    @NSManaged var levelProgressPoints: NSNumber?
    @NSManaged var tier: String?
    @NSManaged var location: String?
    @NSManaged var name: String?
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
    @NSManaged var accountIdentifier: String? //< Transien?
    @NSManaged var isNewUser: NSNumber? //< Transien?
    @NSManaged var isVIPSubscriber: NSNumber? //< Transient (so that validation only comes from the backend and is never read from disk?
    @NSManaged var vipEndDate: NSDate? //< Transien?
    @NSManaged var achievementsUnlocked: AnyObject?
    @NSManaged var v_avatarBadgeType: String?
    @NSManaged var content: Set<NSObject>?
}