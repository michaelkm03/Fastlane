//
//  ApplicationTrackingRequestScheduler.swift
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc class ApplicationTrackingRequestScheduler: NSObject, TrackingRequestScheduler {
    
    var batchFiringTimeInterval: NSTimeInterval = 30.0
    
    /// The array that stores the scheduled tracking requests to be fired
    private var trackingRequestsArray = [NSURLRequest]()
    private var timer = VTimerManager()
    private let requestQueue = dispatch_queue_create("TrackingRequestSchedulerQueue", DISPATCH_QUEUE_SERIAL)
    
    convenience init(batchFiringInterval batchInterval: Double?) {
        self.init()
        if let batchTime = batchInterval {
            switch batchTime {
            case 1...60:
                batchFiringTimeInterval = batchTime
            default:
                print("batchFiringTimeInterval should have a range between 1s and 60s")
                break;
            }
        }
    }
    
    func scheduleRequest(request: NSURLRequest) {
        trackingRequestsArray.append(request)
        if !timer.isValid() {
            timer = VTimerManager.scheduledTimerManagerWithTimeInterval(batchFiringTimeInterval, target: self, selector: "sendAllQueuedRequests", userInfo: nil, repeats: true)
        }
    }
    
    func sendAllQueuedRequests() {
        while trackingRequestsArray.count > 0 {
            let request = trackingRequestsArray.removeFirst()
            sendSingleRequest(request)
        }
        self.timer.invalidate()
    }
    
    func cancelAllQueuedRequests() {
        timer.invalidate()
        trackingRequestsArray.removeAll()
    }
    
    func numberOfQueuedRequests() -> Int{
        return trackingRequestsArray.count
    }
    
    func sendSingleRequest(request: NSURLRequest) {
        /// Use a serial queue to esure order
        dispatch_async(requestQueue) {
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request)
            dataTask.resume()
        }
    }
}
