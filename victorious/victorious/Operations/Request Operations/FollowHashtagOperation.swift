//
//  FollowHashtagOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FollowHashtagOperation: RequestOperation {
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    private let request: FollowHashtagRequest
    
    required init(hashtag: String) {
        self.request = FollowHashtagRequest(hashtag: hashtag)
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            let persistentHashtag: VHashtag = context.v_findOrCreateObject( [ "tag" : self.request.hashtag ] )
            persistentHashtag.tag = self.request.hashtag
            
            // Find or create the following relationship
            // TODO: See if you can use just the IDs instead of the obejcts as values in this dictionary
            let followedHashtag: VFollowedHashtag = context.v_findOrCreateObject( [ "user" : currentUser ] )
            followedHashtag.user = currentUser
            followedHashtag.hashtag = persistentHashtag
            followedHashtag.displayOrder = -1
            
            context.v_save()
            
            self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
            self.trackingManager.trackEvent(VTrackingEventUserDidFollowHashtag)
        }
    }
}
