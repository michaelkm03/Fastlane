//
//  UserUpvoteRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUpvoteRemoteOperation: RemoteFetcherOperation, RequestOperation {
    let request: UserUpvoteRequest!
    
    init?(userID: Int, userUpvoteAPIPath: APIPath) {
        guard let request = UserUpvoteRequest(userID: userID, userUpvoteAPIPath: userUpvoteAPIPath) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
