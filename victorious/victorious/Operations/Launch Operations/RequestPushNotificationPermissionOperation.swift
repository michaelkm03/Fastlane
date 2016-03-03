//
//  RequestPushNotificationPermissionOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class RequestPushNotificationPermissionOperation: BackgroundOperation {
    
    // MARK: - Override
    
    override init() {
        super.init()
        qualityOfService = .UserInteractive
    }
    
    override func start() {
        super.start()
        
        dispatch_async( dispatch_get_main_queue() ) {
            guard !self.cancelled && !VPushNotificationManager.sharedPushNotificationManager().started else {
                self.finishedExecuting()
                return
            }
            
            self.beganExecuting()
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "userRespondedToPushNotification",
                name: VPushNotificationManagerDidReceiveResponse,
                object: VPushNotificationManager.sharedPushNotificationManager())
            VPushNotificationManager.sharedPushNotificationManager().startPushNotificationManager()
            
            self.finishedExecuting()
        }
    }
    
    // MARK: - Notification Observer
    
    func userRespondedToPushNotification() {
        onPermissionGranted()
    }
    
    // MARK: - Internal
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func onPermissionGranted() {
        finishedExecuting()
    }
    
}
