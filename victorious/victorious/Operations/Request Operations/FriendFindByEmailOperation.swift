//
//  FriendFindByEmailOperation.swift
//  victorious
//
//  Created by Michael Sena on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FriendFindByEmailOperation: RequestOperation, ResultsOperation {

    private(set) var results: [AnyObject]?
    var didResetResults = false
    
    private var resultObjectIDs = [NSManagedObjectID]()
    private var request: FriendFindByEmailRequest
    
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
    
    internal func onComplete( results: FriendFindByEmailRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            for foundFriend in results {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId": foundFriend.userID])
                persistentUser.populate(fromSourceModel: foundFriend)
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

