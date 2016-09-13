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
    func testValidFlaggingSequenceRequest() {
        let contentID: String = "123"
        let request = ContentFlagRequest(apiPath: APIPath(templatePath: "www.google.com/%%CONTENT_ID%%"), contentID: contentID)
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
