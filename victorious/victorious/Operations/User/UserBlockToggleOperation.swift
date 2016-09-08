//
//  UserBlockToggleOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class UserBlockToggleOperation: SyncOperation<Void> {
    private let user: UserModel
    private let blockAPIPath: APIPath
    private let unblockAPIPath: APIPath
    
    init(user: UserModel, blockAPIPath: APIPath, unblockAPIPath: APIPath) {
        self.user = user
        self.blockAPIPath = blockAPIPath
        self.unblockAPIPath = unblockAPIPath
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute() -> OperationResult<Void> {
        if user.isBlocked {
            user.unblock()
            guard let unblockRequest = UserUnblockRequest(userID: user.id, userUnblockAPIPath: unblockAPIPath) else {
                let error = NSError(domain: "UnblockRequest", code: 1, userInfo: nil)
                return .failure(error)
            }
            let unblockOperation = RequestOperation(request: unblockRequest)
            unblockOperation.rechainAfter(self).queue()
        }
        else {
            user.block()
            guard let blockRequest = UserBlockRequest(userID: user.id, userBlockAPIPath: blockAPIPath) else {
                let error = NSError(domain: "BlockRequest", code: 2, userInfo: nil)
                return .failure(error)
            }
            
            let blockOperation = RequestOperation(request: blockRequest)
            blockOperation.rechainAfter(self).queue()
        }

        return .success()
    }
}
