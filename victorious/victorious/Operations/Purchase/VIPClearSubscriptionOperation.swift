//
//  VIPClearSubscriptionOperation.swift
//  victorious
//
//  Created by Jarod Long on 9/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class VIPClearSubscriptionOperation: SyncOperation<Void> {
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        guard var user = VCurrentUser.user else {
            return .cancelled
        }

        user.vipStatus = nil
        VCurrentUser.update(to: user)
        return .success()
    }
}
