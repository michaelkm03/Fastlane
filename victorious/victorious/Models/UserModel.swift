//
//  UserModel.swift
//  victorious
//
//  Created by Tian Lan on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Conformers are models that store information about a user in the app
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
protocol UserModel: PreviewImageContainer {
    var id: Int { get }
    var email: String? { get }
    var name: String? { get }
    var completedProfile: Bool? { get }
    var location: String? { get }
    var tagline: String? { get }
    var fanLoyalty: FanLoyalty? { get }
    var isBlockedByCurrentUser: Bool? { get }
    var accessLevel: User.AccessLevel? { get }
    var isFollowedByCurrentUser: Bool? { get }
    var likesGiven: Int? { get }
    var likesReceived: Int? { get }
    var previewImageModels: [ImageAssetModel] { get }
    var avatarBadgeType: AvatarBadgeType { get }
    var vipStatus: VIPStatus? { get }
}

extension User: UserModel {
    var previewImageModels: [ImageAssetModel] {
        return previewImages.map { $0 }
    }
}

extension VUser: UserModel {
    
    var id: Int {
        return remoteId.integerValue
    }
    
    var completedProfile: Bool? {
        return v_completedProfile?.boolValue
    }
    
    var fanLoyalty: FanLoyalty? {
        guard let level = self.level?.integerValue,
            let progress = self.levelProgressPercentage?.integerValue else {
                return nil
        }
        let achievements = achievementsUnlocked as? [String] ?? []
        return FanLoyalty(level: level, progress: progress, points: levelProgressPoints?.integerValue, tier: self.tier, achievementsUnlocked: achievements)
    }
    
    var isBlockedByCurrentUser: Bool? {
        return isBlockedByMainUser?.boolValue
    }
    
    var accessLevel: User.AccessLevel? {
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
    
    var previewImageModels: [ImageAssetModel] {
        return previewAssets?.flatMap { $0 } ?? []
    }
    
    var avatarBadgeType: AvatarBadgeType {
        if v_avatarBadgeType == AvatarBadgeType.Verified.stringRepresentation {
            return .Verified
        } else {
            return .None
        }
    }
    
    var vipStatus: VIPStatus? {
        let isVIP = isVIPSubscriber?.boolValue ?? false
        return VIPStatus(isVIP: isVIP, endDate: vipEndDate)
    }
}
