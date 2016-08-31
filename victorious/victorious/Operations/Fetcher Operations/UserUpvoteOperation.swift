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
        VCurrentUser.upvoteUser(with: userID)
        
        UserUpvoteRemoteOperation(
            userID: userID,
            userUpvoteAPIPath: userUpvoteAPIPath
        )?.after(self).queue()
    }
}
