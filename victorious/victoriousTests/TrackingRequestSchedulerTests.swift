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
    private let requestScheduler = TrackingRequestScheduler(batchFiringInterval: 1)
    
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
        trackingRequestRecords.removeAll()
    }
    
    func testBatchFiringTrackingRequests() {
        let async = VAsyncTestHelper()
        var firedRequestsCount = 0
        
        for index in 0..<trackingRequestRecords.count {
            let record = trackingRequestRecords[index]
            stubRequest("GET", record.urlString).andDo{ [unowned self] (header: AutoreleasingUnsafeMutablePointer<NSDictionary?>, status: UnsafeMutablePointer<Int>, body: AutoreleasingUnsafeMutablePointer<LSHTTPBody?>) -> Void in
                firedRequestsCount++
                if index == self.trackingRequestRecords.count - 1 {
                    async.signal()
                }
            }
            requestScheduler.addRequestToArray(trackingRequest: record.request)
        }
        
        async.waitForSignal(3)
        XCTAssert(firedRequestsCount == trackingRequestRecords.count, "Some requests are not successfully fired")
    }
}
