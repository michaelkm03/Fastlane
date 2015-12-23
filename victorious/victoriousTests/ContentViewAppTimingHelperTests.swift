//
//  ContentViewAppTimingHelperTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import Nocilla
@testable import victorious

class ContentViewAppTimingHelperTests: XCTestCase {
    
    func test() {
        let timingTracker = MockTimingTracker()
        let helper = AppTimingContentHelper(timingTracker: timingTracker)
        helper.start()
        
        XCTAssertEqual( timingTracker.eventsStarted.count, 1 )
        XCTAssertEqual( timingTracker.eventsStarted[0], VAppTimingEventTypeContentViewLoad )
        XCTAssertEqual( timingTracker.eventsEnded.count, 0 )
        
        for endpoint in ContentViewEndpoint.allCases {
            helper.setEndpointFinished( endpoint )
            if endpoint != Array(ContentViewEndpoint.allCases).last {
                XCTAssertEqual( timingTracker.eventsEnded.count, 0 )
            }
        }
        
        XCTAssertEqual( timingTracker.eventsEnded.count, 1 )
        XCTAssertEqual( timingTracker.eventsEnded[0], VAppTimingEventTypeContentViewLoad )
    }
}
