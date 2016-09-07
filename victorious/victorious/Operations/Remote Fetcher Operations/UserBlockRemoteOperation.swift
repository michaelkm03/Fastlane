//
//  UserBlockRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserBlockRemoteOperation: RemoteFetcherOperation {
    let request: UserBlockRequest!
    
    init?(userID: Int, userBlockAPIPath: APIPath) {
        guard let request = UserBlockRequest(userID: userID, userBlockAPIPath: userBlockAPIPath) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil)
    }
}
