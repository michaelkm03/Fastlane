//
//  UserUnupvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class UserUnupvoteOperation: FetcherOperation {
    private let userUnupvoteAPIPath: APIPath
    private let user: UserModel
    
    init(user: UserModel, userUnupvoteAPIPath: APIPath) {
        self.user = user
        self.userUnupvoteAPIPath = userUnupvoteAPIPath
    }
    
    override func main() {
        user.unUpvote()
        
        UserUnupvoteRemoteOperation(
            userID: user.id,
            userUnupvoteAPIPath: userUnupvoteAPIPath
        )?.after(self).queue()
    }
}
