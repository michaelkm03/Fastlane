//
//  ContentDeleteRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class ContentDeleteRequestTests: XCTestCase {
    func testInvalidRequest() {
        let contentID: String = "123"
        let request = ContentDeleteRequest(contentID: contentID, apiPath: APIPath(templatePath: "$%^&"))
        XCTAssertNil(request)
    }
    
    func testValidFlaggingSequenceRequest() {
        let contentID: String = "123"
        let request = ContentDeleteRequest(contentID: contentID, apiPath: APIPath(templatePath: "www.google.com/%%CONTENT_ID%%"))
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
