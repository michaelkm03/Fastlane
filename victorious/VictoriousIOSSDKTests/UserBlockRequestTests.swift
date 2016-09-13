//
//  UserBlockRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//
import VictoriousIOSSDK
import XCTest

class UserBlockRequestTests: XCTestCase {
    func testBadRequest() {
        let request = UserBlockRequest(apiPath: APIPath(templatePath: "#$%^&"), userID: 123)
        XCTAssertNil(request)
    }
    
    func testRequest() {
        let request = UserBlockRequest(apiPath: APIPath(templatePath: "www.google.com/%%USER_ID%%"), userID: 123)
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
