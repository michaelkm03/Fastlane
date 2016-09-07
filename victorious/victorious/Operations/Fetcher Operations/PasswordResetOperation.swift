//
//  PasswordResetOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PasswordResetOperation: RemoteFetcherOperation {
    
    let request: PasswordResetRequest!
    
    init(newPassword: String, userToken: String, deviceToken: String) {
        self.request = PasswordResetRequest(newPassword: newPassword, userToken: userToken, deviceToken: deviceToken)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
