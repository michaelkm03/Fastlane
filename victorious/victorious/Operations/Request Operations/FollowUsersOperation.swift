//
//  FollowUsersOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FollowUsersOperation: FetcherOperation {

    var eventTracker: VEventTracker = VTrackingManager.sharedInstance()
    
    let userIDs: [Int]
    let sourceScreenName: String
    
    required init(userIDs: [Int], sourceScreenName: String) {
        self.userIDs = userIDs
        self.sourceScreenName = sourceScreenName
        super.init()
        
        FollowUsersRemoteOperation(userIDs: userIDs, sourceScreenName: sourceScreenName).queueAfter(self)
    }
    
    convenience init(userID: Int, sourceScreenName: String) {
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
    }
}

class FollowUsersRemoteOperation: RequestOperation {
    
    let sourceScreenName: String
    
    private let request: FollowUsersRequest
    private let userIDs: [Int]
    
    required init(userIDs: [Int], sourceScreenName: String) {
        self.userIDs = userIDs
        self.sourceScreenName = sourceScreenName
        self.request = FollowUsersRequest(userIDs: userIDs, sourceScreenName: sourceScreenName)
    }
    
    override func main() {
        self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
    }
}
