//
//  UserUnupvoteRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//
import VictoriousIOSSDK
import XCTest

class UserUnupvoteRequestTests: XCTestCase {
    func testBadRequest() {
        let request = UserUnupvoteRequest(apiPath: APIPath(templatePath: "#$%^&"), userID: 123)
        XCTAssertNil(request)
    }
    
    func testRequest() {
        let request = UserUnupvoteRequest(apiPath: APIPath(templatePath: "www.google.com/%%USER_ID%%"), userID: 123)
        XCTAssertEqual(request?.urlRequest.url?.absoluteString, "www.google.com/123")
    }
}
