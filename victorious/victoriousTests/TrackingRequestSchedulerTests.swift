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
    private struct URLRequestRecord {
        var request: NSURLRequest {
            return NSURLRequest(URL: NSURL(string: urlString)!)
        }
        var urlString: String
        var hasFired: Bool
    }
    private var trackingRequestRecords = [URLRequestRecord]()
    private let requestScheduler = TrackingRequestScheduler(batchFiringInterval: 1)
    
    override func setUp() {
        super.setUp()
        
        LSNocilla.sharedInstance().start()
        
        trackingRequestRecords.append(URLRequestRecord(urlString: "http://www.google.com", hasFired: false))
        trackingRequestRecords.append(URLRequestRecord(urlString: "http://www.apple.com", hasFired: false))
        trackingRequestRecords.append(URLRequestRecord(urlString: "http://www.yahoo.com", hasFired: false))
    }
    
    override func tearDown() {
        super.tearDown()
        
        LSNocilla.sharedInstance().stop()
        trackingRequestRecords.removeAll()
    }
    
    func testBatchFiringTrackingRequests() {
        for var record in trackingRequestRecords {
            stubRequest("GET", record.urlString).andDo{ (header: AutoreleasingUnsafeMutablePointer<NSDictionary?>, status: UnsafeMutablePointer<Int>, body: AutoreleasingUnsafeMutablePointer<LSHTTPBody?>) -> Void in
                record.hasFired = true
            }
            requestScheduler.addRequestToArray(trackingRequest: record.request)
        }
        
        NSThread.sleepForTimeInterval(3)
        for record in trackingRequestRecords {
            XCTAssert(record.hasFired, "tracking request to \(record.urlString) was not successfully sent")
        }
    }
}
