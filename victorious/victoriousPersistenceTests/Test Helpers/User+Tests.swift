//
//  User+Tests.swift
//  victorious
//
//  Created by Michael Sena on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
@testable import VictoriousIOSSDK

extension User {

    init(userID: Int, vipStatus: VIPStatus? = nil) {
        self.userID = userID
        self.email = nil
        self.name = nil
        self.completedProfile = nil
        self.location = nil
        self.tagline = nil
        self.fanLoyalty = nil
        self.isBlockedByMainUser = nil
        self.accessLevel = nil
        self.isDirectMessagingDisabled = nil
        self.isFollowedByMainUser = nil
        self.numberOfFollowers = nil
        self.numberOfFollowing = nil
        self.likesReceived = nil
        self.likesGiven = nil
        self.profileImageURL = nil
        self.tokenUpdatedAt = nil
        self.previewImageAssets = nil
        self.maxVideoUploadDuration = nil
        self.avatar = nil
        self.vipStatus = vipStatus
    }
}
