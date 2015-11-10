//
//  MarkConversationReadRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class MarkConversationReadRequestTests: XCTestCase {
    
    func testConfiguredRequest () {
        let markConversationReadRequest = MarkConversationReadRequest(conversationID: 3797)
        XCTAssertEqual(markConversationReadRequest.urlRequest.URL, NSURL(string: "/api/message/mark_conversation_read"))
        XCTAssertEqual(markConversationReadRequest.conversationID, 3797)
        XCTAssertEqual(markConversationReadRequest.urlRequest.HTTPMethod, "POST")
        let expectedPostValues = ["conversation_id":3797].vsdk_urlEncodedString().dataUsingEncoding(NSUTF8StringEncoding)
        XCTAssertEqual(markConversationReadRequest.urlRequest.HTTPBody, expectedPostValues)
    }
    
}
