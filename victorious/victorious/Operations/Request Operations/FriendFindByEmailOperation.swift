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
    private(set) var results: [AnyObject]?
    
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
            var resultObjectIDs = [NSManagedObjectID]()
            for foundFriend in results {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId": foundFriend.userID])
                persistentUser.populate(fromSourceModel: foundFriend)
                resultObjectIDs.append(persistentUser.objectID)
            }
            context.v_save()
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.results = self.reloadFromMainContext(resultObjectIDs)
                completion()
            }
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
}
