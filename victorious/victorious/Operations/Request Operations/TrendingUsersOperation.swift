//
//  TrendingUsersOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class TrendingUsersOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: TrendingUsersRequest! = TrendingUsersRequest()
    
    private var resultObjectIDs = [NSManagedObjectID]()
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete( networkResult: TrendingUsersRequest.ResultType ) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            var persistentUsers = [VUser]()
            for networkUser in networkResult {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId": networkUser.userID])
                persistentUser.populate(fromSourceModel: networkUser)
                persistentUsers.append(persistentUser)
            }
            context.v_save()
            self.resultObjectIDs = persistentUsers.map { $0.objectID }
            
            dispatch_sync( dispatch_get_main_queue() ) {
                self.results = self.fetchResults()
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
