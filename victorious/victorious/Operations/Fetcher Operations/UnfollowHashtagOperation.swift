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
        // Removed body alongside deprecation of VFollowedHashtag
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
