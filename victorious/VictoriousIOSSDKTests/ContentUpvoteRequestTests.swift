//
//  ContentUpvoteRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class ContentUpvoteRequestTests: XCTestCase {
    func testBadRequest() {
        let request = ContentUpvoteRequest(contentID: "123", contentUpvoteURL: "#$%^&")
        XCTAssertNil(request)
    }
    
    func testRequest() {
        let request = ContentUpvoteRequest(contentID: "123", contentUpvoteURL: "www.google.com/%%CONTENT_ID%%")
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
