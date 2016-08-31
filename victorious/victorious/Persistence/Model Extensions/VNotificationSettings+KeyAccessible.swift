//
//  NotificationSettings+KeyAccessible.swift
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
