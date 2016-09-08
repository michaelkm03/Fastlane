//
//  UserUnblockRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUnblockRemoteOperation: RemoteFetcherOperation {
    let request: UserUnblockRequest!
    
    init?(userID: Int, userUnblockAPIPath: APIPath) {
        guard let request = UserUnblockRequest(userID: userID, userUnblockAPIPath: userUnblockAPIPath) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
