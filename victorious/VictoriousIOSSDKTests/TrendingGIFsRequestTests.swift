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
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("TrendingGIFsResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let trendingGIFs = TrendingGIFsRequest()
            let results = try trendingGIFs.parseResponse(NSURLResponse(), toRequest: trendingGIFs.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 15)
            XCTAssertEqual(results[0].gifURL, "https://media2.giphy.com/media/6T1xoDuIVI5WM/giphy.gif")
            XCTAssertEqual(results[0].mp4URL, "https://media2.giphy.com/media/6T1xoDuIVI5WM/giphy.mp4")
            XCTAssertEqual(results[1].gifURL, "https://media0.giphy.com/media/xy6d8j1gO7XuE/giphy.gif")
            XCTAssertEqual(results[1].mp4URL, "https://media0.giphy.com/media/xy6d8j1gO7XuE/giphy.mp4")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
        let trendingGIFs = TrendingGIFsRequest(paginator:paginator)
        XCTAssertEqual(trendingGIFs.urlRequest.URL?.absoluteString, "/api/image/trending_gifs/1/100")
    }
}
