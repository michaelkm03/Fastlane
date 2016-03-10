//
//  UnblockUserRequestTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class UnblockUserRequestTests: XCTestCase {

    func testRequest() {
        let request = UnblockUserRequest(userID: 10)
        XCTAssertEqual(request.urlRequest.URL?.absoluteString, "/api/user/unblock")
    }
}
