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
    
    func onComplete( results: [User], completion:()->() ) {
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            self.resultObjectIDs = results.flatMap {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId" : $0.userID])
                persistentUser.populate(fromSourceModel: $0)
                return persistentUser.objectID
            }
            context.v_save()
            
            self.results = self.fetchResults()
            completion()
            
            return context
        }
    }
    
    private func fetchResults() -> [VUser] {
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
