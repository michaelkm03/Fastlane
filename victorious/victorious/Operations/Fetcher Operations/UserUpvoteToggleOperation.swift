//
//  UserUpvoteToggleOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUpvoteToggleOperation: FetcherOperation {
    private let userID: Int
    private let upvoteAPIPath: APIPath
    private let unupvoteAPIPath: APIPath
    
    init(userID: Int, upvoteAPIPath: APIPath, unupvoteAPIPath: APIPath) {
        self.userID = userID
        self.upvoteAPIPath = upvoteAPIPath
        self.unupvoteAPIPath = unupvoteAPIPath
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let user: VUser = context.v_findObjects(["remoteId": self.userID]).first else {
                return
            }
            
            if user.isFollowedByCurrentUser == true {
                UserUnupvoteOperation(
                    userID: self.userID,
                    userUnupvoteAPIPath: self.unupvoteAPIPath
                    ).rechainAfter(self).queue()
            }
            else {
                UserUpvoteOperation(
                    userID: self.userID,
                    userUpvoteAPIPath: self.upvoteAPIPath
                    ).rechainAfter(self).queue()
            }
        }
    }
}
