//
//  UserUpvoteToggleOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUpvoteToggleOperation: FetcherOperation {
    private let user: UserModel
    private let upvoteAPIPath: APIPath
    private let unupvoteAPIPath: APIPath
    
    init(user: UserModel, upvoteAPIPath: APIPath, unupvoteAPIPath: APIPath) {
        self.user = user
        self.upvoteAPIPath = upvoteAPIPath
        self.unupvoteAPIPath = unupvoteAPIPath
    }
    
    override func main() {
        if user.isFollowedByCurrentUser == true {
            UserUnupvoteOperation(userID: user.id, userUnupvoteAPIPath: self.unupvoteAPIPath).rechainAfter(self).queue()
        }
        else {
            UserUpvoteOperation(userID: user.id, userUpvoteAPIPath: self.upvoteAPIPath).rechainAfter(self).queue()
        }
    }
}
