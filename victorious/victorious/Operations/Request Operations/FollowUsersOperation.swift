//
//  FollowUsersOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FollowUsersOperation: RequestOperation {

    var eventTracker: VEventTracker = VTrackingManager.sharedInstance()
    
    private let request: FollowUsersRequest
    private let sourceScreenName: String?
    private let userIDs: [Int]
    
    required init(userIDs: [Int], sourceScreenName: String? = nil) {
        self.userIDs = userIDs
        self.sourceScreenName = sourceScreenName
        self.request = FollowUsersRequest(userIDs: userIDs, sourceScreenName: sourceScreenName)
    }
    
    convenience init(userID: Int, sourceScreenName: String? = nil) {
        self.init( userIDs: [userID], sourceScreenName: sourceScreenName )
    }

    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let subjectUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            for userID in self.userIDs {
                guard let objectUser: VUser = context.v_findObjects(["remoteId" : userID]).first
                    where objectUser.remoteId != subjectUser.remoteId else {
                        continue
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
                
            }
            context.v_save()
        }

        self.eventTracker.trackEvent(VTrackingEventUserDidFollowUser)
        self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
    }
}
