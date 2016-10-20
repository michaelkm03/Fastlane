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
    var lastParams: [AnyHashable: Any]!
    var lastSessionParams: [AnyHashable: Any]!
    
    func trackEvent(_ eventName: String?, parameters: [AnyHashable: Any]?, sessionParameters: [AnyHashable: Any]?) {
        lastEvent = eventName
        lastParams = parameters
        lastSessionParams = sessionParameters
    }
    
    func trackEvent(_ eventName: String?, parameters: [AnyHashable: Any]? ) {
        lastEvent = eventName
        lastParams = parameters
        lastSessionParams = nil
    }
    
    func trackEvent(_ eventName: String?  ) {
        lastEvent = eventName
        lastParams = nil
        lastSessionParams = nil
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
            "tracking": [
                "app_time": [testTemplateURL]
            ]
        ]
        let dependencyManager = VDependencyManager(parentManager: nil, configuration: config, dictionaryOfClassesByTemplateName: nil)
        trackerWithDefaultURL = DefaultTimingTracker.sharedInstance()
        trackerWithDefaultURL.setDependencyManager( dependencyManager! )
		trackerWithDefaultURL.tracker = mockTracker
    }
    
    func testInitializer() {
        XCTAssertEqual(templateTracker.apiPaths.count, 1)
        XCTAssertEqual(templateTracker.apiPaths[0].templatePath, testTemplateURL)
        XCTAssertEqual(trackerWithDefaultURL.apiPaths.count, 1)
    }
    
    func testEvents() {
        trackerWithDefaultURL.startEvent(type: eventType, subtype: eventSubtype)
        XCTAssertNil( mockTracker.lastEvent )
        XCTAssertNil( mockTracker.lastParams )
        
        Thread.sleep(forTimeInterval: 1.0)
        
        trackerWithDefaultURL.endEvent(type: eventType, subtype: eventSubtype)
        
        XCTAssertEqual( mockTracker.lastEvent, VTrackingEventApplicationPerformanceMeasured )
        
        let urls = mockTracker.lastParams?[ VTrackingKeyUrls ] as? [String] ?? []
        XCTAssertEqual( urls.count, 1 )
        if urls.count >= 1 {
            XCTAssertEqual( urls[0], testTemplateURL )
        }
        
        let duration = Double(mockTracker.lastParams![VTrackingKeyDuration] as! Int)
        XCTAssertEqualWithAccuracy( duration, 1000.0, accuracy: 100.0)
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
