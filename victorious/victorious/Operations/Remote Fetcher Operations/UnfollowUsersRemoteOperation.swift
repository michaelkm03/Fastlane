//
//  UnfollowUsersRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class UnfollowUserRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: UnfollowUserRequest!
    
    init( userID: Int, sourceScreenName: String) {
        self.request = UnfollowUserRequest(userID: userID, sourceScreenName: sourceScreenName)
    }
    
    override func main() {
        self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
    }
}
