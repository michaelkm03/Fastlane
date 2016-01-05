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

    private(set) var results: [VUser]?
    
    private let emails: [String]
    private let request: FriendFindByEmailRequest
    
    init(emails: [String]) {
        self.emails = emails
        self.request = FriendFindByEmailRequest(emails: emails)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: self.onComplete, onError: nil)
    }
    
    private func onComplete( results: FriendFindByEmailRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            for foundFriend in results {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId": NSNumber(longLong: foundFriend.userID)])
                persistentUser.populate(fromSourceModel: foundFriend)
            }
            context.v_save()
            
            self.persistentStore.mainContext.v_performBlock() { context in
                
                var mainQueueUsers = [VUser]()
                for foundFriend in results {
                    let mainQueuePersistentUser: VUser = context.v_findOrCreateObject(["remoteId": NSNumber(longLong: foundFriend.userID)])
                    mainQueueUsers.append(mainQueuePersistentUser)
                }
                self.results = mainQueueUsers
                completion()
            }
        }
    }
}

