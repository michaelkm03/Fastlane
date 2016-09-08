//
//  UserUpvoteToggleOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUpvoteToggleOperation: SyncOperation<Void> {
    private let user: UserModel
    private let upvoteAPIPath: APIPath
    private let unupvoteAPIPath: APIPath
    
    init(user: UserModel, upvoteAPIPath: APIPath, unupvoteAPIPath: APIPath) {
        self.user = user
        self.upvoteAPIPath = upvoteAPIPath
        self.unupvoteAPIPath = unupvoteAPIPath
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        if user.isUpvoted {
            user.unUpvote()
            guard let unUpvoteRequest = UserUnupvoteRequest(userID: user.id, userUnupvoteAPIPath: unupvoteAPIPath) else {
                let error = NSError(domain: "UnUpvoteRequest", code: 1, userInfo: nil)
                return .failure(error)
            }
            
            let unUpvoteOperation = RequestOperation(request: unUpvoteRequest)
            unUpvoteOperation.after(self).queue()
        }
        else {
            user.upvote()
            guard let upvoteRequest = UserUpvoteRequest(userID: user.id, userUpvoteAPIPath: upvoteAPIPath) else {
                let error = NSError(domain: "UpvoteRequest", code: 2, userInfo: nil)
                return .failure(error)
            }
            
            let upvoteOperation = RequestOperation(request: upvoteRequest)
            upvoteOperation.after(self).queue()
        }
        
        return .success()
    }
}
