//
//  TrendingHashtagRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class TrendingHashtagRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("TrendingHashtagResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let trendingHashtagRequest = TrendingHashtagRequest()
            let results = try trendingHashtagRequest.parseResponse(NSURLResponse(), toRequest: trendingHashtagRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].tag, "surfing")
            XCTAssertEqual(results[1].tag, "bikes")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testDiscoverRequest() {
        let trendingHashtagRequest = TrendingHashtagRequest()
        XCTAssertEqual(trendingHashtagRequest.urlRequest.URL?.absoluteString, "/api/discover/hashtags")
    }

    func testSearchRequest() {
        let hashtagRequest = HashtagSearchRequest(searchTerm: "blah blah 🍞")
        let urlRequest = hashtagRequest.urlRequest
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/hashtag/search/blah%20blah%20%F0%9F%8D%9E/1/15")
    }
}
