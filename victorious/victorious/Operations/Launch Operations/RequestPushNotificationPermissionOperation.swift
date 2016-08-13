//
//  RequestPushNotificationPermissionOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

final class RequestPushNotificationPermissionOperation: SyncOperation<Void> {
    
    override var scheduleQueue: NSOperationQueue {
        return .mainQueue()
    }
    
    override func execute() -> OperationResult<Void> {
        guard !VPushNotificationManager.sharedPushNotificationManager().started else {
            return .cancelled
        }

        VPushNotificationManager.sharedPushNotificationManager().startPushNotificationManager()
        return .success()
    }
}
