//
//  TrackingRequestScheduler.swift
//  victorious
//
//  Created by Tian Lan on 10/28/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

/// This object collects tracking network requests and fire them in batch
/// in a certain time interval (The interval is determined by property batchFiringTimeInterval)
@objc class TrackingRequestScheduler: NSObject {
    
    /// The interval (number of seconds) at which this scheduler batch fires tracking network requests
    var batchFiringTimeInterval = 30.0
    
    private var trackingRequestsArray = [NSURLRequest]()
    private var timer = VTimerManager()
    private let requestQueue = dispatch_queue_create("TrackingRequestSchedulerQueue", DISPATCH_QUEUE_SERIAL)

    private struct Constants {
        static let singleFiringTimeInterval = 0.5
    }
    
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
    
    /// Adds a request to `trackingRequestsArray` and send it out in next `sendAllQueuedRequests()`
    func scheduleRequest(request: NSURLRequest) {
        trackingRequestsArray.append(request)
        if !timer.isValid() {
            timer = VTimerManager.scheduledTimerManagerWithTimeInterval(batchFiringTimeInterval, target: self, selector: "sendAllQueuedRequests", userInfo: nil, repeats: true)
        }
    }
    
    /// Sends out all the tracking network requests stored in `trackingRequestsArray`.
    /// Waits for a short period of time (`singleFiringTimeInterval`) after each request to preserve order
    func sendAllQueuedRequests() {
        while trackingRequestsArray.count > 0 {
            let request = trackingRequestsArray.removeFirst()
            sendSingleRequest(request)
        }
        self.timer.invalidate()
    }
    
    private func sendSingleRequest(request: NSURLRequest) {
        dispatch_async(requestQueue, {
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request)
            dataTask.resume()
            NSThread.sleepForTimeInterval(Constants.singleFiringTimeInterval)
        })
    }
}
