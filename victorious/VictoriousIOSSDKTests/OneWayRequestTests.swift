//
//  OneWayRequestTests.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/21/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import XCTest

class OneWayRequestTests: XCTestCase {
    
    func testOneWayRequest() {
        let url = NSURL(string: "http://www.example.com/abc")
        let oneWayRequest = OneWayRequest(url: url!)
        XCTAssertEqual(url, oneWayRequest.urlRequest.URL)
    }
}
