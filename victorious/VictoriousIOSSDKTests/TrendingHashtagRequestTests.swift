//
//  TrendingHashtagsRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class TrendingHashtagsRequestTests: XCTestCase {
    func testResponseParsing() {
        guard
            let mockResponseDataURL = Bundle(for: type(of: self)).url(forResource: "TrendingHashtagResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockResponseDataURL)
        else {
            XCTFail("Error reading mock json data")
            return
        }
        
        do {
            let trendingHashtagsRequest = TrendingHashtagsRequest(apiPath: APIPath(templatePath: "foo"))
            let results = try trendingHashtagsRequest.parseResponse(URLResponse(), toRequest: trendingHashtagsRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].tag, "surfing")
            XCTAssertEqual(results[1].tag, "bikes")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testCustomTrendingRequest() {
        let urlString = "testingURL"
        let trendingHashtagsRequest = TrendingHashtagsRequest(apiPath: APIPath(templatePath: urlString))
        XCTAssertEqual(trendingHashtagsRequest?.urlRequest.url?.absoluteString, urlString)
    }
}
