//
//  FriendFindByEmailOperation.swift
//  victorious
//
//  Created by Michael Sena on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FriendFindByEmailOperation: RequestOperation {

    private(set) var users: [VUser]?
    
    private var request: FriendFindByEmailRequest
    
    internal(set) var friendsFound: [AnyObject]?
    
    init(request: FriendFindByEmailRequest) {
        self.request = request
    }
    
    convenience init?(emails: [String]) {
        if let request = FriendFindByEmailRequest(emails: emails) {
            self.init(request: request)
        } else {
            return nil
        }
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: self.onComplete, onError: nil)
    }
    
    // Move this back to being private once we are able to test main/completion handling
    internal func onComplete( results: FriendFindByEmailRequest.ResultType, completion:()->() ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            var resultObjectIDs = [NSManagedObjectID]()
            for foundFriend in results {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId": foundFriend.userID])
                persistentUser.populate(fromSourceModel: foundFriend)
                resultObjectIDs.append(persistentUser.objectID)
            }
            context.v_save()
            
            self.friendsFound = self.reloadFromMainContext(resultObjectIDs)
            completion()
        }
    }
    
    private func reloadFromMainContext( resultObjectIDs: [NSManagedObjectID] ) -> [VUser] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            var mainQueueUsers = [VUser]()
            for foundFriendObjectID in resultObjectIDs {
                let mainQueuePersistentUser: VUser? = context.objectWithID(foundFriendObjectID) as? VUser
                if let mainQueuePersistentUser = mainQueuePersistentUser {
                    mainQueueUsers.append(mainQueuePersistentUser)
                }
            }
            return mainQueueUsers
        }
    }
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func fetchResults() -> [AnyObject] {
        return self.results ?? []
    }
    
    func clearResults() { }
}

