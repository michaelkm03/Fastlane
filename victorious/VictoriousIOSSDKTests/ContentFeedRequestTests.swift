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
        let apiPath = APIPath(templatePath: "API_PATH")
        let request = ContentFeedRequest(apiPath: apiPath, payloadType: .regular)!
        XCTAssertEqual(request.urlRequest.url?.absoluteString, apiPath.url!.absoluteString)
        XCTAssertEqual(request.urlRequest.httpMethod, "GET")
    }
    
    func testParseResponse() {
        guard
            let mockUserDataURL = Bundle(for: type(of: self)).url(forResource: "ViewedContentsResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockUserDataURL)
        else {
            XCTFail("Error reading mock json data")
            return
        }
        
        let apiPath = APIPath(templatePath: "API_PATH")
        let request = ContentFeedRequest(apiPath: apiPath, payloadType: .regular)!
        do {
            let feedResult = try request.parseResponse(URLResponse(), toRequest: URLRequest(url: URL(string: "foo")!), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(feedResult.contents.count, 2)
            XCTAssertEqual(feedResult.contents.first?.id, "20711")
            XCTAssertEqual(feedResult.contents.last?.id, "20712")
            XCTAssertEqual(feedResult.refreshStage?.contentID, "21253")
            XCTAssertEqual(feedResult.refreshStage?.section, StageSection.main)
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
    }
}
