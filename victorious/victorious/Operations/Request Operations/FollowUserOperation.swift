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
        persistentStore.backgroundContext.v_performBlockAndWait { context in
            guard let objectUser: VUser = context.v_findObject( ["remoteId" : self.userToFollowID] ),
                let subjectUser = VCurrentUser.user(inManagedObjectContext: context) else {
                    return
            }
            
            objectUser.numberOfFollowers = objectUser.numberOfFollowers + 1
            subjectUser.numberOfFollowing = subjectUser.numberOfFollowing + 1
            objectUser.isFollowedByMainUser = true
            
            // Find or create the following relationship
            let uniqueElements = [ "subjectUser" : subjectUser, "objectUser" : objectUser ]
            let followedUser: VFollowedUser = context.v_findOrCreateObject( uniqueElements )
            followedUser.objectUser = objectUser
            followedUser.subjectUser = subjectUser

            // By setting display order to -1, the user will appear at the top
            // of each list of fetched results until a refresh of the followers list
            // comes back from the server with updated display order
            followedUser.displayOrder = -1
            
            context.v_save()

            self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
        }
            
        self.eventTracker.trackEvent(VTrackingEventUserDidFollowUser)
    }
}
