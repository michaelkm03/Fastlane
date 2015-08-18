//
//  AutoplayTrackingHelper.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class AutoplayTrackingEvent : NSObject {
    var name: String
    var urls: AnyObject
    var loadTime: NSNumber?
    var context: StreamCellContext?
    
    init(name: String, urls: AnyObject) {
        self.name = name
        self.urls = urls
    }
}

@objc protocol AutoplayTracking {
    optional func trackAutoplayEvent(event: AutoplayTrackingEvent)
    optional func trackingContext() -> StreamCellContext
}