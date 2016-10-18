//
//  VDependencyManager+ButtonTrackingTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 10/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VDependencyManagerButtonTrackingTests: XCTestCase {
    func testTrackingButtonTap() {
        let macro = "%%AWESOME_MACRO%%"
        let replacementValue = "is_indeed_awesome"
        let trackingKey = "reply.tracking"
        let dependencyManager = VDependencyManager(dictionary:
            [
                trackingKey: [
                    ButtonTrackingEvent.tap.rawValue: ["http://example.com/tracking?awesome_query_parameter=\(macro)"]
                ]
            ])
        let eventTracker = TestTrackingManager()
        let macroReplacements = [macro: "is_indeed_awesome"]
        dependencyManager.trackButtonEvent(.tap, for: trackingKey, with: macroReplacements, eventTracker: eventTracker)

        let trackingCalls = eventTracker.trackEventCalls
        XCTAssertEqual(trackingCalls.count, 1)
        let trackingCall = trackingCalls[0]
        guard
            let eventName = trackingCall.eventName,
            let parameters = trackingCall.parameters
        else {
            XCTFail("Failed to get the tracking event data")
            return
        }

        XCTAssertEqual(eventName, ButtonTrackingEvent.tap.rawValue)
        XCTAssertEqual(parameters[VTrackingKeyUrls] as! [String], ["http://example.com/tracking?awesome_query_parameter=\(replacementValue)"])
    }
}
