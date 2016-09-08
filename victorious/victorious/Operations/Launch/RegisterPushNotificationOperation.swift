//
//  RegisterPushNotificationOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class RegisterPushNotificationOperation: RemoteFetcherOperation {
    
    let request: RegisterPushNotificationRequest!
    
    init(pushNotificationID: String) {
        self.request = RegisterPushNotificationRequest(pushNotificationID: pushNotificationID)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
