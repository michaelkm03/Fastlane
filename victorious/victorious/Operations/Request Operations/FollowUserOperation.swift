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
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    private let request: FollowUserRequest
    private let userID: Int64
    
    required init(userID: Int64, screenName: String) {
        self.userID = userID
        self.request = FollowUserRequest(userID: userID, screenName: screenName)
    }
    
    override func main() {
        persistentStore.backgroundContext.v_performBlockAndWait { context in
            let persistedUserID = NSNumber(longLong: self.userID)
            
            guard let objectUser: VUser = context.v_findObjects(["remoteId" : persistedUserID]).first,
                let subjectUser = VUser.currentUser(inManagedObjectContext: context) else {
                    return
            }
            
            objectUser.isFollowedByMainUser = true
            objectUser.numberOfFollowers = (objectUser.numberOfFollowers?.integerValue ?? 0) + 1
            subjectUser.numberOfFollowing = (subjectUser.numberOfFollowing?.integerValue ?? 0) + 1
            
            // Find or create the following relationship
            let uniqueElements = [ "subjectUser" : subjectUser, "objectUser" : objectUser ]
            let followedUser: VFollowedUser = context.v_findOrCreateObject( uniqueElements )
            followedUser.objectUser = objectUser
            followedUser.subjectUser = subjectUser
            followedUser.displayOrder = -1
            
            context.v_save()
            
            self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
            self.trackingManager.trackEvent(VTrackingEventUserDidFollowUser)
        }
    }
}
