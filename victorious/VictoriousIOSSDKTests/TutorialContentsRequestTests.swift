
//
//  TutorialContentsRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class TutorialContentsRequestTests: XCTestCase {
    
    fileprivate let apiPath = APIPath(templatePath: "https://www.google.com")
    
    func testRequest() {
        let request = TutorialContentsRequest(apiPath: apiPath)
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, apiPath.url?.absoluteString)
    }
    
    func testParseResponse() {
        guard let mockResponseDataURL = Bundle(for: type(of: self)).url(forResource: "ViewedContentsResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = TutorialContentsRequest(apiPath: apiPath)!
            let results = try request.parseResponse(URLResponse(), toRequest: request.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results.first?.id, "20711")
            XCTAssertEqual(results.last?.id, "20712")
        } catch {
            XCTFail("Parse Response Failed.")
        }
    }
}
