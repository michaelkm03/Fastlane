//
//  UnfollowHashtagOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UnfollowHashtagOperation: RequestOperation {
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    private let request: UnfollowHashtagRequest
    
    required init(hashtag: String) {
        self.request = UnfollowHashtagRequest(hashtag: hashtag)
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            // Find the following relationship using VFollowedHashtag
            let uniqueElements = [ "user" : currentUser, "hashtag.tag" : self.request.hashtag ]
            if let followedHashtag: VFollowedHashtag = context.v_findObjects( uniqueElements ).first {
                followedHashtag.hashtag.isFollowedByMainUser = false
                // TODO: Use batch delete
                context.deleteObject( followedHashtag )
            }
            context.v_save()
        }
        
        self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
        self.trackingManager.trackEvent(VTrackingEventUserDidUnfollowHashtag)
    }
}
