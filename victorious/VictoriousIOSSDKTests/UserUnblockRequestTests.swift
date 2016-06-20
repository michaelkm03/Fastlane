//
//  UserUnblockRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//
import VictoriousIOSSDK
import XCTest

class UserUnblockRequestTests: XCTestCase {
    func testBadRequest() {
        let request = UserUnblockRequest(userID: 123, userUnblockAPIPath: APIPath(templatePath: "#$%^&"))
        XCTAssertNil(request)
    }
    
    func testRequest() {
        let request = UserUnblockRequest(userID: 123, userUnblockAPIPath: APIPath(templatePath: "www.google.com/%%USER_ID%%"))
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
