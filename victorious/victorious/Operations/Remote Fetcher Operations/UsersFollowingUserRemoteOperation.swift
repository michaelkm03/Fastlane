//
//  UsersFollowingUserRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class UsersFollowingUserRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: FollowersListRequest
    
    private var userID: Int
    
    required init( request: FollowersListRequest ) {
        self.userID = request.userID
        self.request = request
    }
    
    convenience init( userID: Int ) {
        self.init( request: FollowersListRequest(userID: userID) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( results: SequenceLikersRequest.ResultType) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            // The user being followed
            let objectUser: VUser = context.v_findOrCreateObject([ "remoteId" : self.userID ])
            
            var displayOrder = self.request.paginator.displayOrderCounterStart
            for user in results {
                
                // Load a user who is following self.userID according to the results
                let subjectUser: VUser = context.v_findOrCreateObject( ["remoteId" : user.id] )
                subjectUser.populate(fromSourceModel: user)
                
                // Find or create the following relationship
                let uniqueElements = [ "subjectUser": subjectUser, "objectUser": objectUser ]
                let followedUser: VFollowedUser = context.v_findOrCreateObject( uniqueElements )
                followedUser.objectUser = objectUser
                followedUser.subjectUser = subjectUser
                followedUser.displayOrder = displayOrder
                displayOrder += 1
            }
            context.v_save()
        }
    }
}
