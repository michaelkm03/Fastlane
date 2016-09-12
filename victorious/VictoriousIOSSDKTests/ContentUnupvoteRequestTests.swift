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
    func testRequest() {
        let request = ContentUnupvoteRequest(apiPath: APIPath(templatePath: "www.google.com/%%CONTENT_ID%%"), contentID: "123")
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "www.google.com/123")
    }
}
