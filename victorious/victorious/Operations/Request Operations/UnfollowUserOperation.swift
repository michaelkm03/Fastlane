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
    private let userID: Int64
    
    init( userID: Int64, screenName: String ) {
        self.userID = userID
        self.request = UnfollowUserRequest(userID: userID, screenName: screenName)
    }
    
    override func main() {
        persistentStore.backgroundContext.v_performBlockAndWait { context in
            let persistedUserID = NSNumber(longLong: self.userID)
            
            guard let objectUser: VUser = context.v_findObjects(["remoteId" : persistedUserID]).first,
                let subjectUser = VUser.currentUser(inManagedObjectContext: context) else {
                    return
            }
            
            objectUser.isFollowedByMainUser = false
            objectUser.numberOfFollowers = (objectUser.numberOfFollowers?.integerValue ?? 1) - 1
            subjectUser.numberOfFollowing = (subjectUser.numberOfFollowing?.integerValue ?? 1) - 1
            
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
