//
//  UserUnblockOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUnblockOperation: FetcherOperation {
    private let unblockAPIPath: APIPath
    private let user: UserModel
    
    init(user: UserModel, unblockAPIPath: APIPath) {
        self.user = user
        self.unblockAPIPath = unblockAPIPath
    }
    
    override func main() {
        user.unblock()
        
        UserUnblockRemoteOperation(
            userID: user.id,
            userUnblockAPIPath: unblockAPIPath
        )?.after(self).queue()
    }
}
