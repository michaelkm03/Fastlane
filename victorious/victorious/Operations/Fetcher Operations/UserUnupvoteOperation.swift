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
        VCurrentUser.unUpvoteUser(with: userID)
        
        UserUnupvoteRemoteOperation(
            userID: userID,
            userUnupvoteAPIPath: userUnupvoteAPIPath
        )?.after(self).queue()
    }
}
