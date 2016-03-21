//
//  UnfollowUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UnfollowUserOperation: FetcherOperation {
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    let userID: Int
    let sourceScreenName:String
    
    init( userID: Int, sourceScreenName: String ) {
        self.userID = userID
        self.sourceScreenName = sourceScreenName
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
            
            let uniqueElements = [ "subjectUser" : subjectUser, "objectUser" : objectUser ]
            if let followedUser: VFollowedUser = context.v_findObjects( uniqueElements ).first {
                objectUser.v_removeObject(followedUser, from: "followers")
                subjectUser.v_removeObject(followedUser, from: "following")
                context.deleteObject( followedUser )
            }
            
            context.v_save()
        }
        
        UnfollowUserRemoteOperation(userID: userID,sourceScreenName: sourceScreenName).after(self).queue()
        
        self.trackingManager.trackEvent(VTrackingEventUserDidUnfollowUser)
    }
}