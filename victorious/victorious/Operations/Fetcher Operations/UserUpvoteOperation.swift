//
//  UserUpvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUpvoteOperation: FetcherOperation {
    private let userUpvoteURL: String
    private let userID: Int
    
    init(userID: Int, userUpvoteURL: String) {
        self.userID = userID
        self.userUpvoteURL = userUpvoteURL
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
            userUpvoteURL: userUpvoteURL
        )?.after(self).queue()
    }
}
