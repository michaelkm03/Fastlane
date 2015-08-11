//
//  RequestPushNotificationPermissionOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class RequestPushNotificationPermissionOperation : NSOperation {
    
    override init() {
        _executing = false
        _finished = false
        super.init()
    }
    
    override func start() {
        super.start()
        executing = true
        finished = false
        println("starting")
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.onPermissionGranted()
        }
    }
    
    private func onPermissionGranted() {
        executing = false
        finished = true
    }

    private var _executing : Bool
    override var executing : Bool {
        get {return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }

    private var _finished : Bool
    override var finished : Bool {
        get {return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
}
