//
//  DefaultTimingTrackerTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import Nocilla
@testable import victorious

class MockTracker: NSObject, VEventTracker {
    
    var lastEvent: String!
    var lastParams: [NSObject : AnyObject]!
    
    func trackEvent(eventName: String, parameters: [NSObject : AnyObject] ) {
        lastEvent = eventName
        lastParams = parameters
    }
    func trackEvent(eventName: String  ) {
        lastEvent = eventName
        lastParams = nil
    }
}

class DefaultTimingTrackerTests: XCTestCase {
    
    let eventType = "test"
    let eventSubtype = "subtest"
    let testTemplateURL = "/api/tracking/app_time?type=%%TYPE%%&subtype=%%SUBTYPE%%&time=%%DURATION%%"
    var mockTracker: MockTracker!
    var templateTracker: DefaultTimingTracker!
    var trackerWithDefaultURL: DefaultTimingTracker!
    
    override func setUp() {
        super.setUp()
        mockTracker = MockTracker()
		templateTracker = DefaultTimingTracker.sharedInstance()
		templateTracker.tracker = mockTracker
        let config = [
            "tracking" : [
                "app_time" : [testTemplateURL]
            ]
        ]
        let dependencyManager = VDependencyManager(parentManager: nil, configuration: config, dictionaryOfClassesByTemplateName: nil)
        trackerWithDefaultURL = DefaultTimingTracker.sharedInstance()
        trackerWithDefaultURL.setDependencyManager( dependencyManager )
		trackerWithDefaultURL.tracker = mockTracker
    }
    
    func testInitializer() {
        XCTAssertEqual(templateTracker.urls.count, 1)
        XCTAssertEqual(templateTracker.urls[0], testTemplateURL)
        XCTAssertEqual(trackerWithDefaultURL.urls.count, 1)
    }
    
    func testEvents() {
        trackerWithDefaultURL.startEvent(type: eventType, subtype: eventSubtype)
        XCTAssertNil( mockTracker.lastEvent )
        XCTAssertNil( mockTracker.lastParams )
        
        NSThread.sleepForTimeInterval(0.2)
        
        trackerWithDefaultURL.endEvent(type: eventType, subtype: eventSubtype)
        
        XCTAssertEqual( mockTracker.lastEvent, VTrackingEventApplicationPerformanceMeasured )
        
        let urls = mockTracker.lastParams?[ VTrackingKeyUrls ] as? [String] ?? []
        XCTAssertEqual( urls.count, 1 )
        if urls.count >= 1 {
            XCTAssertEqual( urls[0], testTemplateURL )
        }
        
        let duration = mockTracker.lastParams?[VTrackingKeyDuration] as? Float ?? 0.0
        XCTAssertEqualWithAccuracy( duration, 200.0, accuracy: 5.0)
        XCTAssertEqual( mockTracker.lastParams?[VTrackingKeySubtype] as? String, eventSubtype )
        XCTAssertEqual( mockTracker.lastParams?[VTrackingKeyType] as? String, eventType )
    }
    
    func testReset() {
        trackerWithDefaultURL.startEvent(type: eventType + "0", subtype: nil)
        trackerWithDefaultURL.startEvent(type: eventType + "1", subtype: nil)
        trackerWithDefaultURL.startEvent(type: eventType + "2", subtype: nil)
        
        trackerWithDefaultURL.resetEvent(type: eventType + "0")
        trackerWithDefaultURL.endEvent(type: eventType + "0", subtype: nil)
        XCTAssertNil( mockTracker.lastEvent )
        
        mockTracker.lastEvent = nil
        trackerWithDefaultURL.endEvent(type: eventType + "1", subtype: nil)
        XCTAssertNotNil( mockTracker.lastEvent )
        
        mockTracker.lastEvent = nil
        trackerWithDefaultURL.endEvent(type: eventType + "2", subtype: nil)
        XCTAssertNotNil( mockTracker.lastEvent )
    }
    
    func testResetAll() {
        trackerWithDefaultURL.startEvent(type: eventType + "0", subtype: nil)
        trackerWithDefaultURL.startEvent(type: eventType + "1", subtype: nil)
        trackerWithDefaultURL.startEvent(type: eventType + "2", subtype: nil)
        
        trackerWithDefaultURL.resetAllEvents()
        
        trackerWithDefaultURL.endEvent(type: eventType + "0", subtype: eventSubtype)
        XCTAssertNil( mockTracker.lastEvent )
        
        trackerWithDefaultURL.endEvent(type: eventType + "1", subtype: eventSubtype)
        XCTAssertNil( mockTracker.lastEvent )
        
        trackerWithDefaultURL.endEvent(type: eventType + "2", subtype: eventSubtype)
        XCTAssertNil( mockTracker.lastEvent )
    }
}
