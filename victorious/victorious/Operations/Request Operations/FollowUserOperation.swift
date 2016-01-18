//
//  FollowUserOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FollowUserOperation: RequestOperation {

    var eventTracker: VEventTracker = VTrackingManager.sharedInstance()
    
    private let request: FollowUserRequest
    private let screenName: String
    private let userID: Int
    
    required init(userID: Int, screenName: String) {
        self.userID = userID
        self.screenName = screenName
        self.request = FollowUserRequest(userID: userID, screenName: screenName)
    }

    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let objectUser: VUser = context.v_findObjects( ["remoteId" : self.userID] ).first,
                let subjectUser = VCurrentUser.user(inManagedObjectContext: context) else {
                    return
            }
            
            objectUser.numberOfFollowers = objectUser.numberOfFollowers + 1
            subjectUser.numberOfFollowing = subjectUser.numberOfFollowing + 1
            objectUser.isFollowedByMainUser = true
            objectUser.addFollower(subjectUser)

            context.v_save()
        }

        self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
        self.eventTracker.trackEvent(VTrackingEventUserDidFollowUser)
    }
}
