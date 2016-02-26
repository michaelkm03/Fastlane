//
//  UnblockUserOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UnblockUserOperation: FetcherOperation {
    
    private let userID: Int
    
    init( userID: Int ) {
        self.userID = userID
        super.init()
        
        let remoteOperation = UnblockUserRemoteOperation(userID: userID)
        remoteOperation.queue()
    }
}

class UnblockUserRemoteOperation: FetcherOperation, RequestOperation {
    
    let request: UnblockUserRequest!
    
    init( userID: Int ) {
        self.request = UnblockUserRequest(userID: userID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
