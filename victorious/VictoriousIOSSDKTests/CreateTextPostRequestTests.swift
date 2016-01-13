//
//  CreateTextPostRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class CreateTextPostRequestTests: XCTestCase {
    
    func testRequest() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", background: .BackgoundColor(UIColor.blueColor()))
        let request = CreateTextPostRequest(parameters: mockParameters)
        let urlRequest = request.urlRequest
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/text/create")
    }
}
