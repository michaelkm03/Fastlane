//
//  UnfollowUserOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

class UnfollowUserOperation: RequestOperation {
    private let request: UnfollowUserRequest
    private let userToUnfollowID: Int64
    private let currentUserID: Int64
    private let screenName: String

    init(userToUnfollowID: Int64, currentUserID: Int64, screenName: String) {
        self.userToUnfollowID = userToUnfollowID
        self.currentUserID = currentUserID
        self.screenName = screenName
        self.request = UnfollowUserRequest(userToUnfollowID: userToUnfollowID, screenName: screenName)
    }
}
