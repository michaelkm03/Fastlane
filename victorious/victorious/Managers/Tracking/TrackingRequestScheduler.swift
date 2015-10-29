//
//  TrackingRequestScheduler.swift
//  victorious
//
//  Created by Tian Lan on 10/28/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

@objc class TrackingRequestScheduler:NSObject {
    
    private var trackingRequestsArray = [NSURLRequest]()
    private var timer = NSTimer()
    private let requestQueue = dispatch_queue_create("TrackingRequestSchedulerQueue", DISPATCH_QUEUE_SERIAL)
    
    func batchSendRequests() {
        while trackingRequestsArray.count > 0 {
            let request = trackingRequestsArray.removeFirst()
            sendRequest(request)
        }
        self.timer.invalidate()
    }
    
    func addRequestToArray(trackingRequest request: NSURLRequest) {
        trackingRequestsArray.append(request)
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "batchSendRequests", userInfo: nil, repeats: true)
        }
    }
    
    private func sendRequest(request: NSURLRequest) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), requestQueue, {
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request)
            dataTask.resume()
        })
    }
}
