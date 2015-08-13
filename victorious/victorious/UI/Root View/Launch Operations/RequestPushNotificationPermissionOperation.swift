//
//  RequestPushNotificationPermissionOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class RequestPushNotificationPermissionOperation : NSOperation {
    
    private var _executing : Bool
    private var _finished : Bool
    
    override init() {
        _executing = false
        _finished = false
        super.init()
    }
    
    // MARK: - Override
    
    override func start() {
        super.start()
        
        if cancelled || VPushNotificationManager.sharedPushNotificationManager().started {
            executing = false
            finished = true
            return
        }
        
        executing = true
        finished = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userRespondedToPushNotification",
            name: VPushNotificationManagerDidReceiveResponse,
            object: VPushNotificationManager.sharedPushNotificationManager())
        VPushNotificationManager.sharedPushNotificationManager().startPushNotificationManager()
    }
    
    // MARK: - Notification Observer
    
    @objc func userRespondedToPushNotification() {
        onPermissionGranted()
    }
    
    // MARK: - Internal
    
    private func onPermissionGranted() {
        executing = false
        finished = true
    }

    // MARK: - KVO-able NSNotification State
    
    override var executing : Bool {
        get {return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }

    override var finished : Bool {
        get {return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
}
