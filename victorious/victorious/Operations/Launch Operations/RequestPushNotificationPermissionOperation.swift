//
//  RequestPushNotificationPermissionOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class RequestPushNotificationPermissionOperation: MainQueueOperation {
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func start() {
        super.start()
        
        beganExecuting()
        
        guard !cancelled && !VPushNotificationManager.sharedPushNotificationManager().started else {
            finishedExecuting()
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(userRespondedToPushNotification),
            name: VPushNotificationManagerDidReceiveResponse,
            object: VPushNotificationManager.sharedPushNotificationManager())
        VPushNotificationManager.sharedPushNotificationManager().startPushNotificationManager()
    }
    
    // MARK: - Notification Observer
    
    func userRespondedToPushNotification() {
        finishedExecuting()
    }
}
