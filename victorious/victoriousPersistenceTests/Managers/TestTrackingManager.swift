//
//  TestTrackingManager.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

struct TrackingManagerCall {
    let eventName: String?
    let parameters: [NSObject : AnyObject]?
}

class TestTrackingManager: NSObject, VEventTracker {
    
    var trackEventCalls = [TrackingManagerCall]()
    
    func trackEvent(eventName: String, parameters: [NSObject : AnyObject] ) {
        let call = TrackingManagerCall(eventName: eventName, parameters: parameters)
        self.trackEventCalls.append( call )
    }
    
    func trackEvent(eventName: String ) {
        let call = TrackingManagerCall(eventName: eventName, parameters: nil)
        self.trackEventCalls.append( call )
    }
}
