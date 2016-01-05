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
        persistentStore.backgroundContext.v_performBlockAndWait { context in
            guard let currentUser = VUser.currentUser(inManagedObjectContext: context) else {
                return
            }
            
            let persistentHashtag: VHashtag = context.v_findOrCreateObject( [ "tag" : self.request.hashtag ] )
            persistentHashtag.tag = self.request.hashtag
            
            // Find or create the following relationship
            // TODO: See if you can use just the IDs instead of the obejcts as values in this dictionary
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
