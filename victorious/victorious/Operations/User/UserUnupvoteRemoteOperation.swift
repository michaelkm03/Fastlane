//
//  UserUnupvoteRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserUnupvoteRemoteOperation: RemoteFetcherOperation {
    let request: UserUnupvoteRequest!
    
    init?(userID: Int, userUnupvoteAPIPath: APIPath) {
        guard let request = UserUnupvoteRequest(userID: userID, userUnupvoteAPIPath: userUnupvoteAPIPath) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
