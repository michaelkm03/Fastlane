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
    var url: NSURL
    var loadTime: NSNumber?
    
    init(name: String, url: NSURL) {
        self.name = name
        self.url = url
    }
}

@objc protocol AutoplayTracking {
    func trackAutoplayEvent(event: AutoplayTrackingEvent)
}