//
//  FlagConversationRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class FlagConversationRequestTests: XCTestCase {

    func testConfiguredRequest() {
        let flagRequest = FlagConversationRequest(conversationID: 3797)
        XCTAssertEqual(flagRequest.urlRequest.URL, NSURL(string: "/api/message/flag"))
        XCTAssertEqual(flagRequest.conversationID, 3797)
        XCTAssertEqual(flagRequest.urlRequest.HTTPMethod, "POST")
        let expectedPostValues = ["message_id":3797].vsdk_urlEncodedString().dataUsingEncoding(NSUTF8StringEncoding)
        XCTAssertEqual(flagRequest.urlRequest.HTTPBody, expectedPostValues)
    }
}
