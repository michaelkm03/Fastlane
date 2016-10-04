//
//  NotificationSettings.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

struct NotificationSettings {
    var isPostFromCreatorEnabled: Bool = true
    var isNewFollowerEnabled: Bool = true
    var isNewPrivateMessageEnabled: Bool = true
    var isNewCommentOnMyPostEnabled: Bool = true
    var isPostFromFollowedEnabled: Bool = true
    var isPostOnFollowedHashTagEnabled: Bool = true
    var isUserTagInCommentEnabled: Bool = true
    var isPeopleLikeMyPostEnabled: Bool = true
    
    mutating func populate(fromSourceModel sourceModel: NotificationPreference) {
        self.isPostFromCreatorEnabled = sourceModel.contains(.creatorPost)
        self.isNewFollowerEnabled = sourceModel.contains(.newFollower)
        self.isNewPrivateMessageEnabled = sourceModel.contains(.privateMessage)
        self.isNewCommentOnMyPostEnabled = sourceModel.contains(.commentPost)
        self.isPostFromFollowedEnabled = sourceModel.contains(.followPost)
        self.isPostOnFollowedHashTagEnabled = sourceModel.contains(.tagPost)
        self.isUserTagInCommentEnabled = sourceModel.contains(.mention)
        self.isPeopleLikeMyPostEnabled = sourceModel.contains(.likePost)
    }
    
    mutating func updateValue(forKey key: String, newValue: Bool) {
        guard let settingType = NotificationSettingType(rawValue: key) else {
            return
        }
        
        switch settingType {
            case .postFromCreator:
                isPostFromCreatorEnabled = newValue
            case .postFromFavorite:
                isPostFromFollowedEnabled = newValue
            case .mentionsUser:
                isUserTagInCommentEnabled = newValue
            case .upvotePost:
                isPeopleLikeMyPostEnabled = newValue
            case .favoritesUser:
                isNewFollowerEnabled = newValue
            case .privateMessage:
                isNewPrivateMessageEnabled = newValue
        }
    }
    
    func isKeyEnabled(_ key: String) -> Bool {
        guard let settingType = NotificationSettingType(rawValue: key) else {
            return false
        }
        
        switch settingType {
            case .postFromCreator:
                return isPostFromCreatorEnabled
            case .postFromFavorite:
                return isPostFromFollowedEnabled
            case .mentionsUser:
                return isUserTagInCommentEnabled
            case .upvotePost:
                return isPeopleLikeMyPostEnabled
            case .favoritesUser:
                return isNewFollowerEnabled
            case .privateMessage:
                return isNewPrivateMessageEnabled
        }
    }
    
    /// Refer to VTrackingConstants
    func trackingName(forKey key: String) -> String {
        guard let settingType = NotificationSettingType(rawValue: key) else {
            return ""
        }
        
        switch settingType {
            case .postFromCreator:
                return VTrackingValuePostFromCreator
            case .postFromFavorite:
                return VTrackingValuePostFromFollowed
            case .mentionsUser:
                return VTrackingValueUsertagInComment
            case .upvotePost:
                return VTrackingValuePeopleLikeMyPost
            case .favoritesUser:
                return VTrackingValueNewFollower
            case .privateMessage:
                return VTrackingValueNewPrivateMessage
        }
    }
    
    var networkPreferences: [NotificationPreference: Bool] {
        var networkPreferences = [NotificationPreference: Bool]()
        
        networkPreferences[.creatorPost] = self.isPostFromCreatorEnabled
        networkPreferences[.followPost] = self.isPostFromFollowedEnabled
        networkPreferences[.commentPost] = self.isNewCommentOnMyPostEnabled
        networkPreferences[.privateMessage] = self.isNewPrivateMessageEnabled
        networkPreferences[.tagPost] = self.isPostOnFollowedHashTagEnabled
        networkPreferences[.mention] = self.isUserTagInCommentEnabled
        networkPreferences[.likePost] = self.isPeopleLikeMyPostEnabled
        networkPreferences[.newFollower] = self.isNewFollowerEnabled
        
        return networkPreferences
    }
}

enum NotificationSettingType : String {
    case postFromCreator = "notification_creator_post"
    case postFromFavorite = "notification_follow_post"
    case mentionsUser = "notification_mention"
    case upvotePost = "notification_like_post"
    case favoritesUser = "notification_new_follower"
    case privateMessage = "notification_private_message"
}

