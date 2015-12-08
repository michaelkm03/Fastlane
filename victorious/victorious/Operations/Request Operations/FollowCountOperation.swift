//
//  FollowCountOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FollowCountOperation: RequestOperation {
    
    var request: FollowCountRequest
    private let userID: Int64
    
    required init( request: FollowCountRequest ) {
        self.userID = request.userID
        self.request = request
    }
    
    convenience init( userID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: FollowCountRequest(userID: userID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onComplete( response: FollowCountRequest.ResultType, completion:()->() ) {
        persistentStore.asyncFromBackground() { context in
            let user: VUser = context.findOrCreateObject( [ "remoteId" : Int(self.userID) ])
            user.numberOfFollowers = response.followersCount
            user.numberOfFollowing = response.followingCount
            context.saveChanges()
            completion()
        }
    }
}
