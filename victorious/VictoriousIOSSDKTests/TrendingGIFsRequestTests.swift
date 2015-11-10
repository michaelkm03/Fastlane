//
//  TrendingGIFsRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class TrendingGIFsRequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("TrendingGIFsResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let trendingGIFs = TrendingGIFsRequest()
            let (results, _, previousPage) = try trendingGIFs.parseResponse(NSURLResponse(), toRequest: trendingGIFs.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 15)
            XCTAssertEqual(results[0].gifURL, "https://media2.giphy.com/media/6T1xoDuIVI5WM/giphy.gif")
            XCTAssertEqual(results[0].mp4URL, "https://media2.giphy.com/media/6T1xoDuIVI5WM/giphy.mp4")
            
            XCTAssertNil(previousPage, "There should be no page before page 1")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let trendingGIFs = TrendingGIFsRequest(pageNumber: 1, itemsPerPage: 100)
        XCTAssertEqual(trendingGIFs.urlRequest.URL?.absoluteString, "/api/image/trending_gifs/1/100")
    }
}
