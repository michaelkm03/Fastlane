//
//  NotificationSettings.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct NotificationSettings {
    
    public let isPostFromCreatorEnabled = false
    public let isNewFollowerEnabled = false
    public let isNewPrivateMessageEnabled = false
    public let isNewCommentOnMyPostEnabled = false
    public let isPostFromFollowedEnabled = false
    public let isPostOnFollowedHashTagEnabled = false
    public let isUserTagInCommentEnabled = false
    public let isPeopleLIkeMyPostEnabled = false
    
}

extension NotificationSettings {
    public init(json: JSON) {
        self.isPostFromCreatorEnabled = json["notification_creator_post"]
        self.isNewFollowerEnabled = json["notification_new_follower"]
        self.isNewPrivateMessageEnabled = json["notification_private_message"]
        self.isNewCommentOnMyPostEnabled = json["notification_comment_post"]
        self.isPostFromFollowedEnabled = json["notification_follow_post"]
        self.isPostOnFollowedHashTagEnabled = json["notification_tag_post"]
        self.isUserTagInCommentEnabled = json["notification_mention"]
        self.isPeopleLIkeMyPostEnabled = json["notification_like_post"]
    }
}
