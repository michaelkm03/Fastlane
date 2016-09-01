//
//  UserUpvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class UserUpvoteOperation: FetcherOperation {
    private let userUpvoteAPIPath: APIPath
    private let user: UserModel
    
    init(user: UserModel, userUpvoteAPIPath: APIPath) {
        self.user = user
        self.userUpvoteAPIPath = userUpvoteAPIPath
    }
    
    override func main() {
        user.upvote()
        
        UserUpvoteRemoteOperation(
            userID: user.id,
            userUpvoteAPIPath: userUpvoteAPIPath
        )?.after(self).queue()
    }
}
