//
//  HashtagSearchRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class HashtagSearchRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("HashtagSearchResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            guard let hashtagSearch = HashtagSearchRequest(searchTerm: "surfer") else {
                XCTFail("HashtagSearchRequest: Could not create request.")
                return
            }
           let results = try hashtagSearch.parseResponse(NSURLResponse(), toRequest: hashtagSearch.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].tag, "surfer")
            XCTAssertEqual(results[1].tag, "surfer2")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here: \(error)")
        }
    }
    
    func testDefaultRequest() {
        guard let hashtagSearch = HashtagSearchRequest(searchTerm: "surfer") else {
            XCTFail("HashtagSearchRequest: Could not create request.")
            return
        }
        XCTAssertEqual(hashtagSearch.urlRequest.URL?.absoluteString, "/api/hashtag/search/surfer")
    }
}
