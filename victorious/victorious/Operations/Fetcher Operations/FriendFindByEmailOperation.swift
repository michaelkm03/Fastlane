//
//  FriendFindByEmailOperation.swift
//  victorious
//
//  Created by Michael Sena on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FriendFindByEmailOperation: RemoteFetcherOperation, RequestOperation {
    
    private var resultObjectIDs = [NSManagedObjectID]()
    
    let request: FriendFindByEmailRequest!
    
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
    
    func onComplete( results: [User] ) {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            let persistentUsers: [VUser] = results.flatMap {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId" : $0.id])
                persistentUser.populate(fromSourceModel: $0)
                return persistentUser
            }
            context.v_save()
            
            self.resultObjectIDs = persistentUsers.flatMap { $0.objectID }
            self.results = self.fetchResults()
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
