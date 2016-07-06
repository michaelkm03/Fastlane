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
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("TrendingHashtagResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let trendingHashtagRequest = TrendingHashtagRequest(url: nil)
            let results = try trendingHashtagRequest.parseResponse(NSURLResponse(), toRequest: trendingHashtagRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].tag, "surfing")
            XCTAssertEqual(results[1].tag, "bikes")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testDefaultTrendingRequest() {
        let trendingHashtagRequest = TrendingHashtagRequest(url: nil)
        XCTAssertEqual(trendingHashtagRequest.urlRequest.URL?.absoluteString, "/api/discover/hashtags")
    }
    
    func testCustomTrendingRequest() {
        let urlString = "testingURL"
        let trendingHashtagRequest = TrendingHashtagRequest(url: NSURL(string: urlString))
        XCTAssertEqual(trendingHashtagRequest.urlRequest.URL?.absoluteString, urlString)
    }
    
    func testSearchRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 15)
        guard let hashtagRequest = HashtagSearchRequest(searchTerm: "blah blah 🍞", context: nil, paginator: paginator) else {
            XCTFail("HashtagSearchRequest: Could not create request.")
            return
        }
        let urlRequest = hashtagRequest.urlRequest
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/hashtag/search/blah%20blah%20%F0%9F%8D%9E/1/15")
    }
    
    func testSearchRequestContext() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 15)
        for context in [ SearchContext.Message, SearchContext.Discover, SearchContext.UserTag ] {
            guard let hashtagRequest = HashtagSearchRequest(searchTerm: "blah blah 🍞", context: context, paginator: paginator) else {
                XCTFail("HashtagSearchRequest: Could not create request.")
                return
            }
            let urlRequest = hashtagRequest.urlRequest
            XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/hashtag/search/blah%20blah%20%F0%9F%8D%9E/1/15/\(context.rawValue)")
        }
    }
}
