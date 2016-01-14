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
    
    /// `request` is implicitly unwrapped to solve the failable initializer EXC_BAD_ACCESS bug when returning nil
    /// Reference: Swift Documentation, Section "Failable Initialization for Classes":
    /// https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html
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
    
    // Move this back to being private once we are able to test main/completion handling
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

