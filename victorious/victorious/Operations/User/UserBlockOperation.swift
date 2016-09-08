//
//  UserBlockOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class UserBlockOperation: SyncOperation<Void> {
    private let blockAPIPath: APIPath
    private let user: UserModel
    
    init(user: UserModel, blockAPIPath: APIPath) {
        self.user = user
        self.blockAPIPath = blockAPIPath
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute() -> OperationResult<Void> {
        user.block()
        
        guard let request = UserBlockRequest(userID: user.id, userBlockAPIPath: blockAPIPath) else {
            Log.warning("Failed to instantie UserBlockRequest")
            let error = NSError(domain: "UserBlockOperation-RequestInitializationFailed", code: 1, userInfo: nil)
            return .failure(error)
        }
        
        let operation = RequestOperation(request: request)
        operation.after(self).queue()
        
        return .success()
    }
}
