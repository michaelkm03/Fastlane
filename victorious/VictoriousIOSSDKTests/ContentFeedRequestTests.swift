//
//  ContentFeedRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 5/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class ContentFeedRequestTests: XCTestCase {
    
    func testConfiguredRequest() {
        let apiPath: String = "API_PATH"
        let request = ContentFeedRequest(url: NSURL(string: apiPath)!)
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
        let request = ContentFeedRequest(url: NSURL(string: apiPath)!)
        do {
            let (contents, refreshStage) = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(contents.count, 2)
            XCTAssertEqual(contents.first?.id, "20711")
            XCTAssertEqual(contents.last?.id, "20712")
            XCTAssertEqual(refreshStage?.contentID, "21253")
            XCTAssertEqual(refreshStage?.section, StageSection.main)
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
    }
    
}
