//
//  VNotificationSettings+Parsable.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VNotificationSettings {
    
    func populate(fromSourceModel sourceModel: NotificationPreference) {
        self.isPostFromCreatorEnabled = sourceModel.contains(.creatorPost)
        self.isNewFollowerEnabled = sourceModel.contains(.newFollower)
        self.isNewPrivateMessageEnabled = sourceModel.contains(.privateMessage)
        self.isNewCommentOnMyPostEnabled = sourceModel.contains(.commentPost)
        self.isPostFromFollowedEnabled = sourceModel.contains(.followPost)
        self.isPostOnFollowedHashTagEnabled = sourceModel.contains(.tagPost)
        self.isUserTagInCommentEnabled = sourceModel.contains(.mention)
        self.isPeopleLikeMyPostEnabled = sourceModel.contains(.likePost)
    }
    
}

extension VNotificationSettings {
    
    func networkPreferences() -> [NotificationPreference: Bool] {
        var networkPreferences = [NotificationPreference: Bool]()
        
        networkPreferences[.creatorPost] = self.isPostFromCreatorEnabled?.boolValue ?? false
        networkPreferences[.followPost] = self.isPostFromFollowedEnabled?.boolValue ?? false
        networkPreferences[.commentPost] = self.isNewCommentOnMyPostEnabled?.boolValue ?? false
        networkPreferences[.privateMessage] = self.isNewPrivateMessageEnabled?.boolValue ?? false
        networkPreferences[.tagPost] = self.isPostOnFollowedHashTagEnabled?.boolValue ?? false
        networkPreferences[.mention] = self.isUserTagInCommentEnabled?.boolValue ?? false
        networkPreferences[.likePost] = self.isPeopleLikeMyPostEnabled?.boolValue ?? false
        networkPreferences[.newFollower] = self.isNewFollowerEnabled?.boolValue ?? false
        
        return networkPreferences
    }
    
}
