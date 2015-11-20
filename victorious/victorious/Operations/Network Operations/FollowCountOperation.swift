//
//  FollowCountOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FollowCountOperation: RequestOperation<FollowCountRequest> {
    
    private let persistentStore = PersistentStore()
    
    init( userID: Int64 ) {
        super.init( request: FollowCountRequest(userID: userID) )
    }
    
    override func onResponse(response: FollowCountRequest.ResultType) {
        persistentStore.syncFromBackground() { context in
            let user: VUser = context.findOrCreateObject( [ "remoteId" : Int(self.request.userID) ])
            user.numberOfFollowers = response.followersCount
            user.numberOfFollowing = response.followingCount
            context.saveChanges()
        }
    }
}
