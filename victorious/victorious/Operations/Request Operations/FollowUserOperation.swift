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
    private let screenName: String?
    private let userIDs: [Int]
    
    required init(userIDs: [Int], screenName: String? = nil) {
        self.userIDs = userIDs
        self.screenName = screenName
        self.request = FollowUserRequest(userIDs: userIDs, screenName: screenName)
    }
    
    convenience init(userID: Int, screenName: String? = nil) {
        self.init( userIDs: [userID], screenName: screenName )
    }

    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            
            for userID in self.userIDs {
                guard let objectUser: VUser = context.v_findObjects( ["remoteId" : userID] ).first,
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
                followedUser.displayOrder = 0
                
                self.eventTracker.trackEvent(VTrackingEventUserDidFollowUser)
            }

            context.v_save()
        }

        self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
    }
}
