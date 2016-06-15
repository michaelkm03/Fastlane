//
//  UserBlockToggleOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserBlockToggleOperation: FetcherOperation {
    private let userID: Int
    private let blockURL: String
    private let unblockURL: String
    
    init(userID: Int, blockURL: String, unblockURL: String) {
        self.userID = userID
        self.blockURL = blockURL
        self.unblockURL = unblockURL
    }
    
    override func main() {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait({ context in
            guard let user: VUser = context.v_findObjects(["remoteId": self.userID]).first else {
                return
            }
            
            if user.isBlockedByCurrentUser == true {
                UserUnblockOperation(
                    userID: self.userID,
                    unblockURL: self.unblockURL
                ).rechainAfter(self).queue()
            }
            else {
                UserBlockOperation(
                    userID: self.userID,
                    blockURL: self.blockURL
                ).rechainAfter(self).queue()
            }
        })
    }
}
