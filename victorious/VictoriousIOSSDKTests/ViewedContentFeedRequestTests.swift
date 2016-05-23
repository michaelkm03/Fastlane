//
//  ViewedContentFeedRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 5/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class ViewedContentFeedRequestTests: XCTestCase {
    
    func testConfiguredRequest() {
        let apiPath: String = "API_PATH"
        let request =  ViewedContentFeedRequest(apiPath: apiPath)
        XCTAssertEqual( request.urlRequest.URL?.absoluteString, apiPath)
        XCTAssertEqual( request.urlRequest.HTTPMethod, "GET" )
    }
    
    func testParseResponse() {
        
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("ViewedContentsResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let apiPath: String = "API_PATH"
        let request =  ViewedContentFeedRequest(apiPath: apiPath)
        do {
            let response = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(response.count, 2)
            XCTAssertEqual(response.first?.content.id, "20711")
            XCTAssertEqual(response.last?.content.id, "20712")
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
    }
    
}
