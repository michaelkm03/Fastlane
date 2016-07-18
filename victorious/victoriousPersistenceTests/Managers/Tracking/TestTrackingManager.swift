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
    let sessionParameters: [NSObject : AnyObject]?
}

class TestTrackingManager: NSObject, VEventTracker {

    var trackEventCalls = [TrackingManagerCall]()
    
    func trackEvent(eventName: String?, parameters: [NSObject : AnyObject]?, sessionParameters: [NSObject : AnyObject]?) {
        let call = TrackingManagerCall(eventName: eventName, parameters: parameters, sessionParameters: sessionParameters)
        self.trackEventCalls.append(call)
    }

    func trackEvent(eventName: String?, parameters: [NSObject: AnyObject]? ) {
        let call = TrackingManagerCall(eventName: eventName, parameters: parameters, sessionParameters: nil)
        self.trackEventCalls.append(call)
    }

    func trackEvent(eventName: String?) {
        let call = TrackingManagerCall(eventName: eventName, parameters: nil, sessionParameters: nil)
        self.trackEventCalls.append(call)
    }
}
