//
//  UserUnupvoteRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUnupvoteRemoteOperation: RemoteFetcherOperation, RequestOperation {
    let request: UserUnupvoteRequest!
    
    init?(userID: Int, userUnupvoteURL: String) {
        guard let request = UserUnupvoteRequest(userID: userID, userUnupvoteURL: userUnupvoteURL) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
