//
//  HashtagSearchResponseTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class HashtagSearchResponseTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("HashtagSearchResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
            let hashtagSearch = HashtagSearchRequest(searchTerm: "surfer", paginator: paginator)
            let results = try hashtagSearch.parseResponse(NSURLResponse(), toRequest: hashtagSearch.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].hashtagID, 495)
            XCTAssertEqual(results[0].tag, "surfer")
            XCTAssertEqual(results[1].hashtagID, 616)
            XCTAssertEqual(results[1].tag, "surfer2")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
        let hashtagSearch = HashtagSearchRequest(searchTerm: "surfer", paginator: paginator)
        XCTAssertEqual(hashtagSearch.urlRequest.URL?.absoluteString, "/api/hashtag/search/surfer/1/100")
    }
}
