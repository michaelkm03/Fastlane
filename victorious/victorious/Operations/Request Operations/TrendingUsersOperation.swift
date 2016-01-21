//
//  TrendingUsersOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class TrendingUsersOperation: RequestOperation {
    
    let request = TrendingUsersRequest()
    private(set) var results: [VUser]?
    private var resultObjectIDs = [NSManagedObjectID]()
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete( networkResult: TrendingUsersRequest.ResultType, completion: () -> () ) {
        self.results = []
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            for networkUser in networkResult {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId": networkUser.userID])
                persistentUser.populate(fromSourceModel: networkUser)
                self.resultObjectIDs.append(persistentUser.objectID)
            }
            context.v_save()
            
            self.persistentStore.mainContext.v_performBlock() { context in
                var mainQueueUsers = [VUser]()
                for foundFriendObjectID in self.resultObjectIDs {
                    let mainQueuePersistentUser: VUser? = context.objectWithID(foundFriendObjectID) as? VUser
                    if let mainQueuePersistentUser = mainQueuePersistentUser {
                        mainQueueUsers.append(mainQueuePersistentUser)
                    }
                }
                self.results = mainQueueUsers
                completion()
            }
        }
    }
}
