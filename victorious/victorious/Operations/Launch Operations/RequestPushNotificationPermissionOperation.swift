//
//  RequestPushNotificationPermissionOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class RequestPushNotificationPermissionOperation : Operation {
    
    // MARK: - Override
    
    override func start() {
        super.start()
        
        if cancelled || VPushNotificationManager.sharedPushNotificationManager().started {
            finishedExecuting()
            return
        }
        
        beganExecuting()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userRespondedToPushNotification",
            name: VPushNotificationManagerDidReceiveResponse,
            object: VPushNotificationManager.sharedPushNotificationManager())
        VPushNotificationManager.sharedPushNotificationManager().startPushNotificationManager()
    }
    
    // MARK: - Notification Observer
    
    func userRespondedToPushNotification() {
        onPermissionGranted()
    }
    
    // MARK: - Internal
    
    private func onPermissionGranted() {
        finishedExecuting()
    }
    
}
