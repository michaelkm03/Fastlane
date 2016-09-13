//
//  UserBlockOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class UserBlockOperation: FetcherOperation {
    private let blockAPIPath: APIPath
    private let user: UserModel
    
    init(user: UserModel, blockAPIPath: APIPath) {
        self.user = user
        self.blockAPIPath = blockAPIPath
    }
    
    override func main() {
        user.block()
        
        UserBlockRemoteOperation(
            userID: user.id,
            userBlockAPIPath: blockAPIPath
        )?.after(self).queue()
    }
}
