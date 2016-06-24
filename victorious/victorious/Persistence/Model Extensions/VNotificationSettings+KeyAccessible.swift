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
    case postFromFavorite = "notification_follow_posts"
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
}