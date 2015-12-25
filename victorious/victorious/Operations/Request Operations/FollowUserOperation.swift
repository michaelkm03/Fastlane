//
//  FollowUserOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK

class FollowUserOperation: RequestOperation {
    private let request:        FollowUserRequest
    private let userToFollowID: Int64
    private let currentUserID:  Int64
    private let screenName:     String

    init(userToFollowID: Int64, currentUserID: Int64, screenName: String) {
        self.userToFollowID = userToFollowID
        self.currentUserID = currentUserID
        self.screenName = screenName
        self.request = FollowUserRequest(userToFollowID: userToFollowID, screenName: screenName)
    }

    override func main() {
        persistentStore.backgroundContext.v_performBlockAndWait { context in
            let persistedUserToFollowID = NSNumber(longLong: self.userToFollowID)
            let persistedCurrentUserID = NSNumber(longLong: self.currentUserID)
            var needToSave = false

            if let userToFollow: VUser = context.v_findObject(["remoteId" : persistedUserToFollowID]) {
                userToFollow.numberOfFollowers = self.initializeOrIncrease(number: userToFollow.numberOfFollowers)
                needToSave = true
            }

            if let currentUser: VUser = context.v_findObject(["remoteId" : persistedCurrentUserID]) {
                currentUser.numberOfFollowing = self.initializeOrIncrease(number: currentUser.numberOfFollowing)
                needToSave = true
            }

            if needToSave {
                context.v_save()
            }
        }
    }

    private func initializeOrIncrease(number number: NSNumber?) -> NSNumber {
        if let number = number {
            return NSNumber(int: number.integerValue + 1)
        } else {
            return NSNumber(int: 1)
        }
    }
}
