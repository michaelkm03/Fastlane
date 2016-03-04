//
//  FollowCountOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FollowCountOperation: RemoteFetcherOperation, RequestOperation {
    
    var request: FollowCountRequest!
    private let userID: Int
    
    required init( request: FollowCountRequest ) {
        self.userID = request.userID
        self.request = request
    }
    
    convenience init( userID: Int ) {
        self.init( request: FollowCountRequest(userID: userID) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( response: FollowCountRequest.ResultType) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let user: VUser = context.v_findObjects( [ "remoteId" : Int(self.userID) ]).first else {
                return
            }
            
            user.numberOfFollowers = response.followersCount
            user.numberOfFollowing = response.followingCount
            context.v_save()
        }
    }
}
