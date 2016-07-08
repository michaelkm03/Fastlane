//
//  ContentFlagRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class ContentFlagRequestTests: XCTestCase {
    func testInvalidRequest() {
        let contentID: String = "123"
        let request = ContentFlagRequest(contentID: contentID, contentFlagURL: "$%^&")
        XCTAssertNil(request)
    }

    func testValidFlaggingSequenceRequest() {
        let contentID: String = "123"
        let request = ContentFlagRequest(contentID: contentID, contentFlagURL: "www.google.com/%%CONTENT_ID%%")
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
