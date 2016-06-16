//
//  UserUnupvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUnupvoteOperation: FetcherOperation {
    private let userUnupvoteAPIPath: APIPath
    private let userID: Int
    
    init(userID: Int, userUnupvoteAPIPath: APIPath) {
        self.userID = userID
        self.userUnupvoteAPIPath = userUnupvoteAPIPath
    }
    
    override func main() {
        // Make data change optimistically before executing the request
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let user: VUser = context.v_findObjects(["remoteId": self.userID]).first else {
                return
            }
            
            user.isFollowedByMainUser = false
            context.v_save()
        }
        
        UserUnupvoteRemoteOperation(
            userID: userID,
            userUnupvoteAPIPath: userUnupvoteAPIPath
        )?.after(self).queue()
    }
}
