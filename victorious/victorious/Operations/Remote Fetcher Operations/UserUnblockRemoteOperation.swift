//
//  UserUnblockRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUnblockRemoteOperation: RemoteFetcherOperation, RequestOperation {
    let request: UserUnblockRequest!
    
    init?(userID: Int, userUnblockURL: String) {
        guard let request = UserUnblockRequest(userID: userID, userUnblockURL: userUnblockURL) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil)
    }
}
