//
//  UserBlockOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserBlockOperation: FetcherOperation {
    private let blockURL: String
    private let userID: Int
    
    init(userID: Int, blockURL: String) {
        self.userID = userID
        self.blockURL = blockURL
    }
    
    override func main() {
        // Make data change optimistically before executing the request
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let user: VUser = context.v_findObjects(["remoteId": self.userID]).first else {
                return
            }
            
            user.isBlockedByMainUser = true
            context.v_save()
        }
    }
}
