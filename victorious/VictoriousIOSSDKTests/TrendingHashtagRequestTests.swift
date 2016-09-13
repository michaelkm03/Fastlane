//
//  TrendingHashtagRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class TrendingHashtagRequestTests: XCTestCase {
    func testResponseParsing() {
        guard
            let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("TrendingHashtagResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL)
        else {
            XCTFail("Error reading mock json data")
            return
        }
        
        do {
            let trendingHashtagRequest = TrendingHashtagRequest(apiPath: APIPath(templatePath: ""))!
            let results = try trendingHashtagRequest.parseResponse(NSURLResponse(), toRequest: trendingHashtagRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].tag, "surfing")
            XCTAssertEqual(results[1].tag, "bikes")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testCustomTrendingRequest() {
        let urlString = "testingURL"
        let trendingHashtagRequest = TrendingHashtagRequest(apiPath: APIPath(templatePath: urlString))
        XCTAssertEqual(trendingHashtagRequest?.urlRequest.URL?.absoluteString, urlString)
    }
}
