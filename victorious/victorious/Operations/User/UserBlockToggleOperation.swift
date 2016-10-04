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
    fileprivate let user: UserModel
    fileprivate let blockAPIPath: APIPath
    fileprivate let unblockAPIPath: APIPath
    
    init(user: UserModel, blockAPIPath: APIPath, unblockAPIPath: APIPath) {
        self.user = user
        self.blockAPIPath = blockAPIPath
        self.unblockAPIPath = unblockAPIPath
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        if user.isBlocked {
            user.unblock()
            guard let unblockRequest = UserUnblockRequest(apiPath: unblockAPIPath, userID: user.id) else {
                let error = NSError(domain: "UnblockRequest", code: 1, userInfo: nil)
                return .failure(error)
            }
            let unblockOperation = RequestOperation(request: unblockRequest)
            unblockOperation.after(self).queue()
        }
        else {
            user.block()
            guard let blockRequest = UserBlockRequest(apiPath: blockAPIPath, userID: user.id) else {
                let error = NSError(domain: "BlockRequest", code: 2, userInfo: nil)
                return .failure(error)
            }
            
            let blockOperation = RequestOperation(request: blockRequest)
            blockOperation.after(self).queue()
        }

        return .success()
    }
}
