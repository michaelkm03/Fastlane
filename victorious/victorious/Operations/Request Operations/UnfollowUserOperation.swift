//
//  UnfollowUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UnfollowUserOperation: RequestOperation {
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    private let request: UnfollowUserRequest
    private let userID: Int
    
    init( userID: Int, screenName: String ) {
        self.userID = userID
        self.request = UnfollowUserRequest(userID: userID, screenName: screenName)
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let persistedUserID = NSNumber(integer: self.userID)
            
            guard let objectUser: VUser = context.v_findObjects(["remoteId" : persistedUserID]).first,
                let subjectUser = VCurrentUser.user(inManagedObjectContext: context) else {
                    return
            }
            
            objectUser.isFollowedByMainUser = false
            objectUser.numberOfFollowers = objectUser.numberOfFollowers - 1
            subjectUser.numberOfFollowing = subjectUser.numberOfFollowing - 1
            
            // Find the following relationship and delete it
            let uniqueElements = [ "subjectUser" : subjectUser, "objectUser" : objectUser ]
            if let followedUser: VFollowedUser = context.v_findObjects( uniqueElements ).first {
                context.deleteObject( followedUser )
            }
            
            context.v_save()
            
            self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
            self.trackingManager.trackEvent(VTrackingEventUserDidUnfollowUser)
        }
    }
}
