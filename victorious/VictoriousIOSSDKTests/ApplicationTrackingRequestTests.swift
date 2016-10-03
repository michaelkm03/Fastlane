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
        let url = URL(string: "http://www.example.com/")!
        let eventIndex = 20
        let trackingRequest = ApplicationTrackingRequest(trackingURL: url, eventIndex: eventIndex)
        let urlRequest = trackingRequest.urlRequest
        XCTAssertEqual(urlRequest.url, url)
        XCTAssertEqual(urlRequest.value(forHTTPHeader: "X-Client-Event-Index"), "20")
    }
}
