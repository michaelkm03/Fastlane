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
        guard let settingType = VNotificationSettingType(rawValue: key) else {
            return false
        }
        
        switch settingType {
            case .postFromCreator:
                return isPostFromCreatorEnabled?.boolValue ?? false
            case .postFromFavorite:
                return isPostFromFollowedEnabled?.boolValue ?? false
            case .mentionsUser:
                return isUserTagInCommentEnabled?.boolValue ?? false
            case .upvotePost:
                return isPeopleLikeMyPostEnabled?.boolValue ?? false
            case .favoritesUser:
                return isNewFollowerEnabled?.boolValue ?? false
            case .privateMessage:
                return isNewPrivateMessageEnabled?.boolValue ?? false
        }
    }
    
    func updateValue(forKey key: String, newValue: Bool) {
        guard let settingType = VNotificationSettingType(rawValue: key) else {
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
    
    //Refer to VTrackingConstants
    func trackingName(forKey key: String) -> String {
        guard let settingType = VNotificationSettingType(rawValue: key) else {
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
}
