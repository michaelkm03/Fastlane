//
//  TrackingRequestScheduler.swift
//  victorious
//
//  Created by Tian Lan on 10/28/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

/// Defines an object that schedules tracking network requests and executes them in batches
/// at a certain time interval determined by `batchFiringTimeInterval`.
@objc protocol TrackingRequestScheduler {
    
    /// Schedules a request for execution later on when `sendAllQueuedRequests()` is called.
    func scheduleRequest(request: NSURLRequest)
    
    /// Sends out all the tracking network requests currently scheduled
    /// on a serial queue to esure order.
    func sendAllQueuedRequests()
    
    /// Remove all the tracking network requests currently scheduled.
    func cancelAllQueuedRequests()
    
    /// - returns: the number of tracking network requests currently scheduled.
    func numberOfQueuedRequests() -> Int
    
    /// Sends out the provided tracking network request on a serial queue to esure order.
    func sendSingleRequest(request: NSURLRequest)
}
