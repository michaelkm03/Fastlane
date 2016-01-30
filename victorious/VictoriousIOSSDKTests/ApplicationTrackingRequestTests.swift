//
//  ApplicationTrackingRequestTests.swift
//  victorious
//
//  Created by Josh Hinman on 1/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class ApplicationTrackingRequestTests: XCTestCase {

    func testRequest() {
        let url = NSURL(string: "http://www.example.com/")!
        let eventIndex = 20
        let trackingRequest = ApplicationTrackingRequest(trackingURL: url, eventIndex: eventIndex)
        let urlRequest = trackingRequest.urlRequest
        XCTAssertEqual(urlRequest.URL, url)
        XCTAssertEqual(urlRequest.valueForHTTPHeaderField("X-Client-Event-Index"), "20")
    }
}
