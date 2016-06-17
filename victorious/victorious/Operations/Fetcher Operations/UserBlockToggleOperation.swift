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
    private let blockAPIPath: APIPath
    private let unblockAPIPath: APIPath
    
    init(userID: Int, blockAPIPath: APIPath, unblockAPIPath: APIPath) {
        self.userID = userID
        self.blockAPIPath = blockAPIPath
        self.unblockAPIPath = unblockAPIPath
    }
    
    override func main() {
        guard didConfirmActionFromDependencies else {
            cancel()
            return
        }
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let user: VUser = context.v_findObjects(["remoteId": self.userID]).first else {
                return
            }
            
            if user.isBlockedByCurrentUser == true {
                UserUnblockOperation(
                    userID: self.userID,
                    unblockAPIPath: self.unblockAPIPath
                ).rechainAfter(self).queue()
            }
            else {
                UserBlockOperation(
                    userID: self.userID,
                    blockAPIPath: self.blockAPIPath
                ).rechainAfter(self).queue()
            }
        }
    }
}
