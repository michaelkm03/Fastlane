//
//  UserUpvoteRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//
import VictoriousIOSSDK
import XCTest

class UserUpvoteRequestTests: XCTestCase {
    func testBadRequest() {
        let request = UserUpvoteRequest(userID: 123, userUpvoteAPIPath: APIPath(templatePath:"#$%^&"))
        XCTAssertNil(request)
    }
    
    func testRequest() {
        let request = UserUpvoteRequest(userID: 123, userUpvoteAPIPath: APIPath(templatePath:"www.google.com/%%USER_ID%%"))
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
