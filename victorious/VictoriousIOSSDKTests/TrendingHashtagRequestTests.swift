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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
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
            XCTAssertEqual(results[0].hashtagID, 760)
            XCTAssertEqual(results[0].tag, "surfing")
            XCTAssertEqual(results[1].hashtagID, 761)
            XCTAssertEqual(results[1].tag, "bikes")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let trendingHashtagRequest = TrendingHashtagRequest()
        XCTAssertEqual(trendingHashtagRequest.urlRequest.URL?.absoluteString, "/api/discover/hashtags")
    }
}
