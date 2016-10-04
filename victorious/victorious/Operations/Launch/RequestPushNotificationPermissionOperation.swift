//
//  RequestPushNotificationPermissionOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

final class RequestPushNotificationPermissionOperation: SyncOperation<Void> {
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        guard !VPushNotificationManager.shared().started else {
            return .cancelled
        }

        VPushNotificationManager.shared().start()
        return .success()
    }
}
