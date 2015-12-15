//
//  TrackingRequestSchedulerTests.swift
//  victorious
//
//  Created by Tian Lan on 10/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import Nocilla
@testable import victorious

class TrackingRequestSchedulerTests: XCTestCase {
    private struct TrackingRequestRecord {
        var request: NSURLRequest {
            return NSURLRequest(URL: NSURL(string: urlString)!)
        }
        var urlString: String
    }
    private var trackingRequestRecords = [TrackingRequestRecord]()
    
    override func setUp() {
        super.setUp()
        
        LSNocilla.sharedInstance().start()
        
        trackingRequestRecords.append(TrackingRequestRecord(urlString: "http://www.google.com"))
        trackingRequestRecords.append(TrackingRequestRecord(urlString: "http://www.apple.com"))
        trackingRequestRecords.append(TrackingRequestRecord(urlString: "http://www.yahoo.com"))
    }
    
    override func tearDown() {
        super.tearDown()
        
        LSNocilla.sharedInstance().stop()
        LSNocilla.sharedInstance().clearStubs()
        trackingRequestRecords.removeAll()
    }
    
    func testBatchFiringTrackingRequests() {
        var firedRequestsCount = 0
        let requestScheduler = ApplicationTrackingRequestScheduler(batchFiringInterval: 1)
        let expectation = expectationWithDescription("Last tracking requests sent")

        for index in 0..<trackingRequestRecords.count {
            let record = trackingRequestRecords[index]
            stubRequest("GET", record.urlString).andDo{ [unowned self] (_: AutoreleasingUnsafeMutablePointer<NSDictionary?>, _: UnsafeMutablePointer<Int>, _: AutoreleasingUnsafeMutablePointer<LSHTTPBody?>) in
                firedRequestsCount++
                if index == self.trackingRequestRecords.count - 1 {
                    expectation.fulfill()
                }
            }
            requestScheduler.scheduleRequest(record.request)
        }
        
        waitForExpectationsWithTimeout(3, handler: nil)
        XCTAssertEqual(firedRequestsCount, trackingRequestRecords.count, "Some requests are not successfully fired")
    }
    
    func testTrackingRequestsShouldNotFire() {
        var firedRequestsCount = 0
        let requestScheduler = ApplicationTrackingRequestScheduler(batchFiringInterval: 10)
        
        for index in 0..<trackingRequestRecords.count {
            let record = trackingRequestRecords[index]
            stubRequest("GET", record.urlString).andDo{ (_: AutoreleasingUnsafeMutablePointer<NSDictionary?>, _: UnsafeMutablePointer<Int>, _: AutoreleasingUnsafeMutablePointer<LSHTTPBody?>) in
                firedRequestsCount++
            }
            requestScheduler.scheduleRequest(record.request)
        }
        
        XCTAssertTrue(firedRequestsCount == 0, "No requests should be fired at this time")
    }
}
