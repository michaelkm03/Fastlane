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
        let request = UserUnupvoteRequest(userID: 123, userUnupvoteAPIPath: APIPath(templatePath: "#$%^&"))
        XCTAssertNil(request)
    }
    
    func testRequest() {
        let request = UserUnupvoteRequest(userID: 123, userUnupvoteAPIPath: APIPath(templatePath: "www.google.com/%%USER_ID%%"))
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
