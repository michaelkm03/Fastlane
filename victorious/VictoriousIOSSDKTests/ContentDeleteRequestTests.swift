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
    func testValidFlaggingSequenceRequest() {
        let contentID = "123"
        let request = ContentDeleteRequest(contentID: contentID, apiPath: APIPath(templatePath: "www.google.com/%%CONTENT_ID%%"))
        XCTAssertEqual(request.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
