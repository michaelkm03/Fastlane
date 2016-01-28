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
    
    private var resultObjectIDs = [NSManagedObjectID]()
    
    private var request: FriendFindByEmailRequest!
    
    init?(emails: [String]) {
        self.request = FriendFindByEmailRequest(emails: emails)
        super.init()
        if self.request == nil {
            return nil
        }
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: self.onComplete, onError: nil)
    }
    
    func onComplete( results: FriendFindByEmailRequest.ResultType, completion:()->() ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            var persistentUsers = [VUser]()
            for foundFriend in results {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId": foundFriend.userID])
                persistentUser.populate(fromSourceModel: foundFriend)
                persistentUsers.append(persistentUser)
            }
            context.v_save()
            self.resultObjectIDs = persistentUsers.map { $0.objectID }
            
            dispatch_async( dispatch_get_main_queue() ) {
                self.results = self.fetchResults()
                completion()
            }
        }
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            var mainQueueUsers = [VUser]()
            for foundFriendObjectID in self.resultObjectIDs {
                let mainQueuePersistentUser: VUser? = context.objectWithID(foundFriendObjectID) as? VUser
                if let mainQueuePersistentUser = mainQueuePersistentUser {
                    mainQueueUsers.append(mainQueuePersistentUser)
                }
            }
            return mainQueueUsers
        }
    }
}
