//
//  UserUpvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUpvoteOperation: FetcherOperation {
    private let userUpvoteAPIPath: APIPath
    private let userID: Int
    
    init(userID: Int, userUpvoteAPIPath: APIPath) {
        self.userID = userID
        self.userUpvoteAPIPath = userUpvoteAPIPath
    }
    
    override func main() {
        // Make data change optimistically before executing the request
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let user: VUser = context.v_findObjects(["remoteId": self.userID]).first else {
                return
            }
            
            user.isFollowedByMainUser = true
            context.v_save()
        }
        
        UserUpvoteRemoteOperation(
            userID: userID,
            userUpvoteAPIPath: userUpvoteAPIPath
        )?.after(self).queue()
    }
}
