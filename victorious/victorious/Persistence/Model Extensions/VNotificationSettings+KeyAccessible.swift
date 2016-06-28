//
//  VNotificationSettings+KeyAccessible.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//


import Foundation

enum VNotificationSettingType : String {
    case postFromCreator = "notification_creator_post"
    case postFromFavorite = "notification_follow_post"
    case mentionsUser = "notification_mention"
    case upvotePost = "notification_like_post"
    case favoritesUser = "notification_new_follower"
    case privateMessage = "notification_private_message"
}

extension VNotificationSettings {
    func isKeyEnabled(key: String) -> Bool {
        switch key {
        case VNotificationSettingType.postFromCreator.rawValue:
            return isPostFromCreatorEnabled?.boolValue ?? false
        case VNotificationSettingType.postFromFavorite.rawValue:
            return isPostFromFollowedEnabled?.boolValue ?? false
        case VNotificationSettingType.mentionsUser.rawValue:
            return isUserTagInCommentEnabled?.boolValue ?? false
        case VNotificationSettingType.upvotePost.rawValue:
            return isPeopleLikeMyPostEnabled?.boolValue ?? false
        case VNotificationSettingType.favoritesUser.rawValue:
            return isNewFollowerEnabled?.boolValue ?? false
        case VNotificationSettingType.privateMessage.rawValue:
            return isNewPrivateMessageEnabled?.boolValue ?? false
        default:
            return false
        }
    }
    
    func updateValue(forKey key: String, newValue: Bool) {
        switch key {
        case VNotificationSettingType.postFromCreator.rawValue:
            isPostFromCreatorEnabled = newValue
        case VNotificationSettingType.postFromFavorite.rawValue:
            isPostFromFollowedEnabled = newValue
        case VNotificationSettingType.mentionsUser.rawValue:
           isUserTagInCommentEnabled = newValue
        case VNotificationSettingType.upvotePost.rawValue:
            isPeopleLikeMyPostEnabled = newValue
        case VNotificationSettingType.favoritesUser.rawValue:
            isNewFollowerEnabled = newValue
        case VNotificationSettingType.privateMessage.rawValue:
            isNewPrivateMessageEnabled = newValue
        default:
           break
        }
    }
    
    //Refer to VTrackingConstants
    func trackingName(forKey key: String) -> String {
        switch key {
        case VNotificationSettingType.postFromCreator.rawValue:
            return VTrackingValuePostFromCreator
        case VNotificationSettingType.postFromFavorite.rawValue:
            return VTrackingValuePostFromFollowed
        case VNotificationSettingType.mentionsUser.rawValue:
            return VTrackingValueUsertagInComment
        case VNotificationSettingType.upvotePost.rawValue:
            return VTrackingValuePeopleLikeMyPost
        case VNotificationSettingType.favoritesUser.rawValue:
            return VTrackingValueNewFollower
        case VNotificationSettingType.privateMessage.rawValue:
            return VTrackingValueNewPrivateMessage
        default:
            return ""
        }

    }
}