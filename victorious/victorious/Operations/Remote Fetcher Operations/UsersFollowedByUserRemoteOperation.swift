//
//  UsersFollowedByUserRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class UsersFollowedByUserRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: SubscribedToListRequest
    
    private var userID: Int
    
    required init( request: SubscribedToListRequest ) {
        self.userID = request.userID
        self.request = request
    }
    
    convenience init( userID: Int, paginator: StandardPaginator = StandardPaginator() ) {
        self.init( request: SubscribedToListRequest(userID: userID) )
    }
    
    override func main() {
        guard !cancelled else {
            return
        }
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( users: SubscribedToListRequest.ResultType) {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            // The user who is doing the following of other users
            let subjectUser: VUser = context.v_findOrCreateObject([ "remoteId" : self.userID] )
            
            var displayOrder = self.request.paginator.displayOrderCounterStart
            for user in users {
                
                // Load a user who is followed by self.userID according to the results
                let objectUser: VUser = context.v_findOrCreateObject( ["remoteId" : user.id] )
                objectUser.populate(fromSourceModel: user)
                
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
