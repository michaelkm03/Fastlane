//
//  AppTimingStreamHelperTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class AppTimingStreamHelperTests: XCTestCase {
    
    let streamId: String = "test:stream:id"
    
    var timingTracker: MockTimingTracker!
    var helper: AppTimingStreamHelper!
    
    override func setUp() {
        super.setUp()
        
        timingTracker = MockTimingTracker()
        helper = AppTimingStreamHelper(streamId:streamId, timingTracker: timingTracker)
    }
    
    func testFirstPage() {
        helper.startStreamLoadAppTimingEvents( pageType: .Refresh )
        XCTAssertEqual( timingTracker.eventsStarted.count, 1 )
        XCTAssertEqual( timingTracker.eventsStarted[0], VAppTimingEventTypeStreamRefresh )
        
        helper.endStreamLoadAppTimingEvents( pageType: .Refresh )
        XCTAssertEqual( timingTracker.eventsEnded.count, 2 )
        XCTAssertEqual( timingTracker.eventsEnded[0], VAppTimingEventTypeStreamRefresh,
            "2 events should have ended on the first first time." )
        
        timingTracker.eventsEnded = []
        
        helper.endStreamLoadAppTimingEvents( pageType: .Refresh )
        XCTAssertEqual( timingTracker.eventsEnded.count, 1 )
        XCTAssertEqual( timingTracker.eventsEnded[0], VAppTimingEventTypeStreamRefresh,
            "Only 1 event should have ended after the first time." )
    }
    
    func testNextPage() {
        helper.startStreamLoadAppTimingEvents( pageType: .Next )
        XCTAssertEqual( timingTracker.eventsStarted.count, 1 )
        XCTAssertEqual( timingTracker.eventsStarted[0], VAppTimingEventTypeStreamLoad )
        
        helper.endStreamLoadAppTimingEvents( pageType: .Next )
        XCTAssertEqual( timingTracker.eventsEnded.count, 1 )
        XCTAssertEqual( timingTracker.eventsEnded[0], VAppTimingEventTypeStreamLoad )
    }
}
