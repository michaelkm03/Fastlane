//
//  ContentUnupvoteRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class ContentUnupvoteRequestTests: XCTestCase {
    func testBadRequest() {
        let request = ContentUnupvoteRequest(contentID: "123", contentUnupvoteURL: "#$%^&")
        XCTAssertNil(request)
    }
    
    func testRequest() {
        let request = ContentUnupvoteRequest(contentID: "123", contentUnupvoteURL: "www.google.com/%%CONTENT_ID%%")
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
