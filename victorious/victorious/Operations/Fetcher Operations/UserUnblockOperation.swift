//
//  UserUnblockOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUnblockOperation: FetcherOperation {
    private let unblockAPIPath: APIPath
    private let userID: Int
    
    init(userID: Int, unblockAPIPath: APIPath) {
        self.userID = userID
        self.unblockAPIPath = unblockAPIPath
    }
    
    override func main() {
        // Make data change optimistically before executing the request
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let user: VUser = context.v_findObjects(["remoteId": self.userID]).first else {
                return
            }
            
            user.isBlockedByMainUser = false
            context.v_save()
        }
        
        UserUnblockRemoteOperation(
            userID: userID,
            userUnblockAPIPath: unblockAPIPath
        )?.after(self).queue()
    }
}
