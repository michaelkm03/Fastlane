//
//  VNotificationSettings+Parsable.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VNotificationSettings: PersistenceParsable {
    
    func populate(fromSourceModel sourceModel: NotificationPreference) {
        self.isPostFromCreatorEnabled = sourceModel.contains(.CreatorPost)
        self.isNewFollowerEnabled = sourceModel.contains(.NewFollower)
        self.isNewPrivateMessageEnabled = sourceModel.contains(.PrivateMessage)
        self.isNewCommentOnMyPostEnabled = sourceModel.contains(.CommentPost)
        self.isPostFromFollowedEnabled = sourceModel.contains(.FollowPost)
        self.isPostOnFollowedHashTagEnabled = sourceModel.contains(.TagPost)
        self.isUserTagInCommentEnabled = sourceModel.contains(.Mention)
        self.isPeopleLikeMyPostEnabled = sourceModel.contains(.LikePost)
    }
    
}

extension VNotificationSettings {
    
    func networkPreferences() -> [NotificationPreference: Bool] {
        var networkPreferences = [NotificationPreference: Bool]()
        
        networkPreferences[.CreatorPost] = self.isPostFromCreatorEnabled.boolValue
        networkPreferences[.FollowPost] = self.isPostFromFollowedEnabled.boolValue
        networkPreferences[.CommentPost] = self.isNewCommentOnMyPostEnabled.boolValue
        networkPreferences[.PrivateMessage] = self.isNewPrivateMessageEnabled.boolValue
        networkPreferences[.TagPost] = self.isPostOnFollowedHashTagEnabled.boolValue
        networkPreferences[.Mention] = self.isUserTagInCommentEnabled.boolValue
        networkPreferences[.LikePost] = self.isPeopleLikeMyPostEnabled.boolValue
        networkPreferences[.NewFollower] = self.isNewFollowerEnabled.boolValue
        
        return networkPreferences
    }
    
}
