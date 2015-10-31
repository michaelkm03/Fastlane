//
//  TrackingRequestScheduler.swift
//  victorious
//
//  Created by Tian Lan on 10/28/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

@objc class TrackingRequestScheduler:NSObject {
    
    var batchFiringTimeInterval = 30.0
    
    private var trackingRequestsArray = [NSURLRequest]()
    private var timer = NSTimer()
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
    
    func addRequestToArray(trackingRequest request: NSURLRequest) {
        trackingRequestsArray.append(request)
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(batchFiringTimeInterval, target: self, selector: "sendAllQueuedRequests", userInfo: nil, repeats: true)
        }
    }
    
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
