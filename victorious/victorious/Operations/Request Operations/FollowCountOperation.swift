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
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    private let userID: Int64
    
    init( userID: Int64 ) {
        self.userID = userID
        super.init( request: FollowCountRequest(userID: userID) )
    }
    
    override func onComplete(response: FollowCountRequest.ResultType, completion:()->() ) {
        persistentStore.asyncFromBackground() { context in
            let user: VUser = context.findOrCreateObject( [ "remoteId" : Int(self.userID) ])
            user.numberOfFollowers = response.followersCount
            user.numberOfFollowing = response.followingCount
            //context.saveChanges()
            completion()
        }
    }
}
