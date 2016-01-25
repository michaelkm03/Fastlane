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
            
            let persistentHashtag: VHashtag = context.v_findOrCreateObject( [ "tag" : self.request.hashtag ] )
            persistentHashtag.tag = self.request.hashtag
            
            // Find or create the following relationship
            let uniqueElements = [ "user" : currentUser, "hashtag" : self.request.hashtag ]
            if let followedHashtag: VFollowedHashtag = context.v_findObjects( uniqueElements ).first {
                context.deleteObject( followedHashtag )
            }
            
            context.v_save()
            
            self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
            self.trackingManager.trackEvent(VTrackingEventUserDidUnfollowHashtag)
        }
    }
}

class ToggleFollowHashtagOperation: RequestOperation {
    
    private let hashtag: String
    
    required init(hashtag: String) {
        self.hashtag = hashtag
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            let uniqueElements = [ "user" : currentUser, "hashtag" : self.hashtag ]
            if let _: VFollowedHashtag = context.v_findObjects( uniqueElements ).first {
                UnfollowHashtagOperation(hashtag: self.hashtag).queueAfter(self)
          
            } else {
               FollowHashtagOperation(hashtag: self.hashtag).queueAfter(self)
            }
        }
    }
}
