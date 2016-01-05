//
//  FollowUserOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK

class FollowUserOperation: RequestOperation {
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    private let request: FollowUserRequest
    private let userToFollowID: Int64
    private let currentUserID: Int64
    private let screenName: String

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

            if let userToFollow: VUser = context.v_findObject(["remoteId" : persistedUserToFollowID]),
                let currentUser: VUser = context.v_findObject(["remoteId" : persistedCurrentUserID]) {
                    userToFollow.numberOfFollowers = (userToFollow.numberOfFollowers?.integerValue ?? 0) + 1
                    currentUser.numberOfFollowing = (currentUser.numberOfFollowing?.integerValue ?? 0) + 1
                    currentUser.addFollowingObject(userToFollow)
                    userToFollow.isFollowedByMainUser = true
                    context.v_save()
            }
            
            self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
            self.trackingManager.trackEvent(VTrackingEventUserDidFollowUser, parameters: [ : ])
        }
    }
}
