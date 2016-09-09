//
//  UserBlockToggleOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class UserBlockToggleOperation: FetcherOperation {
    private let user: UserModel
    private let blockAPIPath: APIPath
    private let unblockAPIPath: APIPath
    
    init(user: UserModel, blockAPIPath: APIPath, unblockAPIPath: APIPath) {
        self.user = user
        self.blockAPIPath = blockAPIPath
        self.unblockAPIPath = unblockAPIPath
    }
    
    override func main() {
        guard didConfirmActionFromDependencies else {
            cancel()
            return
        }
        
        if user.isBlocked {
            UserUnblockOperation(
                user: user,
                unblockAPIPath: self.unblockAPIPath
                ).rechainAfter(self).queue()
        }
        else {
            UserBlockOperation(
                user: user,
                blockAPIPath: self.blockAPIPath
                ).rechainAfter(self).queue()
        }

    }
}
