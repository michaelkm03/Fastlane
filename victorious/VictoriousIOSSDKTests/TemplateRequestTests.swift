//
//  TemplateRequestTests.swift
//  victorious
//
//  Created by Josh Hinman on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class TemplateRequestTests: XCTestCase {

    func testRequest() {
        let request = TemplateRequest()
        XCTAssertEqual(request.urlRequest.url?.absoluteString, "/api/template")
    }
    
    func testResponseParser() {
        guard let mockResponseDataURL = Bundle(for: type(of: self)).url(forResource: "template", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = TemplateRequest()
            let results = try request.parseResponse(URLResponse(), toRequest: request.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results, mockData)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
