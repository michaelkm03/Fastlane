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
        var hasFired = false
    }
    private var trackingRequestRecords = [TrackingRequestRecord]()
    private let requestScheduler = TrackingRequestScheduler(batchFiringInterval: 1)
    
    override func setUp() {
        super.setUp()
        
        LSNocilla.sharedInstance().start()
        
        trackingRequestRecords.append(TrackingRequestRecord(urlString: "http://www.google.com", hasFired: false))
        trackingRequestRecords.append(TrackingRequestRecord(urlString: "http://www.apple.com", hasFired: false))
        trackingRequestRecords.append(TrackingRequestRecord(urlString: "http://www.yahoo.com", hasFired: false))
    }
    
    override func tearDown() {
        super.tearDown()
        
        LSNocilla.sharedInstance().stop()
        trackingRequestRecords.removeAll()
    }
    
    func testBatchFiringTrackingRequests() {
        requestScheduler.addRequestToArray(trackingRequest: NSURLRequest(URL: NSURL(string: "http:www.nba.com")!))
        
        for var record in trackingRequestRecords {
            stubRequest("GET", record.urlString).andDo{ (header: AutoreleasingUnsafeMutablePointer<NSDictionary?>, status: UnsafeMutablePointer<Int>, body: AutoreleasingUnsafeMutablePointer<LSHTTPBody?>) -> Void in
                record.hasFired = true
            }
            requestScheduler.addRequestToArray(trackingRequest: record.request)
        }
        //TODO
        for result in trackingRequestRecords {
            XCTAssertTrue(result.hasFired, "tracking request to \(result.urlString) was not successfully sent")
        }
    }
}
