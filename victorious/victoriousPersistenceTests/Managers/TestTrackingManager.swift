//
//  TestTrackingManager.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class TestTrackingManager: NSObject, VTracker {
    var trackEventCalls = [(eventName: String?, parameters: [NSObject : AnyObject]?)]()

    func trackEvent(eventName: String?, parameters: [NSObject : AnyObject]?) {
        self.trackEventCalls.append(eventName: eventName, parameters: parameters)
    }
}
