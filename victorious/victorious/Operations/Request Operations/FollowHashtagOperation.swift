//
//  FollowHashtagOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FollowHashtagOperation: FetcherOperation {
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    let hashtag: String
    
    required init(hashtag: String) {
        self.hashtag = hashtag
        super.init()
        
        FollowHashtagRemoteOperation(hashtag: hashtag).queueAfter(self)
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            let persistentHashtag: VHashtag = context.v_findOrCreateObject( [ "tag" : self.hashtag ] )
            persistentHashtag.tag = self.hashtag
            
            // Find or create the following relationship using VFollowedHashtag
            let uniqueElements = [ "user" : currentUser, "hashtag.tag" : self.hashtag ]
            let followedHashtag: VFollowedHashtag = context.v_findOrCreateObject( uniqueElements )
            followedHashtag.user = currentUser
            followedHashtag.hashtag = persistentHashtag
            followedHashtag.displayOrder = 0
            
            context.v_save()
        }
        
        self.trackingManager.trackEvent(VTrackingEventUserDidFollowHashtag)
    }
}


class FollowHashtagRemoteOperation: RequestOperation {
    
    private let request: FollowHashtagRequest
    
    required init(hashtag: String) {
        self.request = FollowHashtagRequest(hashtag: hashtag)
    }
    
    override func main() {
        self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
    }
}
