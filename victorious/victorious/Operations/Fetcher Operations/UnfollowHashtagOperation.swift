//
//  UnfollowHashtagOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UnfollowHashtagOperation: FetcherOperation {
    
    var trackingManager: VEventTracker = VTrackingManager.sharedInstance()
    
    let hashtag: String
    
    required init(hashtag: String) {
        self.hashtag = hashtag
        super.init()
        
        UnfollowHashtagRemoteOperation(hashtag: hashtag).after(self).queue()
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            // Find the following relationship using VFollowedHashtag
            let uniqueElements = [ "user": currentUser, "hashtag.tag": self.hashtag ]
            if let followedHashtag: VFollowedHashtag = context.v_findObjects( uniqueElements ).first {
                context.deleteObject( followedHashtag )
            }
            context.v_save()
        }
        
        self.trackingManager.trackEvent(VTrackingEventUserDidUnfollowHashtag)
    }
}


class UnfollowHashtagRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: UnfollowHashtagRequest!
    
    required init(hashtag: String) {
        self.request = UnfollowHashtagRequest(hashtag: hashtag)
    }
    
    override func main() {
        self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
    }
}
