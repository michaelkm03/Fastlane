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
    private let upvoteURL: String
    private let unupvoteURL: String
    
    init(userID: Int, upvoteURL: String, unupvoteURL: String) {
        self.userID = userID
        self.upvoteURL = upvoteURL
        self.unupvoteURL = unupvoteURL
    }
    
    override func main() {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait({ context in
            guard let user: VUser = context.v_findObjects(["remoteId": self.userID]).first else {
                return
            }
            
            if content.v_isLikedByCurrentUser == true {
                ContentUnupvoteOperation(
                    contentID: self.contentID,
                    contentUnupvoteURL: self.unupvoteURL
                    ).rechainAfter(self).queue()
            }
            else {
                ContentUpvoteOperation(
                    contentID: self.contentID,
                    contentUpvoteURL: self.upvoteURL
                    ).rechainAfter(self).queue()
            }
        })
    }
}
