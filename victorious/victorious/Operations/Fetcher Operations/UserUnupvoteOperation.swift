//
//  UserUnupvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUnupvoteOperation: FetcherOperation {
    private let userUnupvoteURL: String
    private let userID: Int
    
    init(userID: Int, userUnupvoteURL: String) {
        self.userID = userID
        self.userUnupvoteURL = userUnupvoteURL
    }
    
    override func main() {
        // Make data change optimistically before executing the request
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let user: VUser = context.v_findObjects(["remoteId": self.userID]).first else {
                return
            }
            
            user.isFollowedByMainUser = false
            context.v_save()
        }
        
        UserUnupvoteRemoteOperation(
            userID: userID,
            userUnupvoteURL: userUnupvoteURL
        )?.after(self).queue()
    }
}
