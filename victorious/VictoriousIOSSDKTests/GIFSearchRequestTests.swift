//
//  GIFSearchRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

import VictoriousIOSSDK
import XCTest

class GIFSearchRequestTests: XCTestCase {
    let searchOptions = GIFSearchOptions.Search(term: "lol", url: "testURL")
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("GIFSearchResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let searchGIFs = GIFSearchRequest(searchOptions: searchOptions)
            let results = try searchGIFs.parseResponse(NSURLResponse(), toRequest: searchGIFs.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 15)
            XCTAssertEqual(results[0].gifURL, "https://media2.giphy.com/media/KxufLEowgK7Xa/giphy.gif")
            XCTAssertEqual(results[0].mp4URL, "https://media2.giphy.com/media/KxufLEowgK7Xa/giphy.mp4")
            XCTAssertEqual(results[1].gifURL, "https://media1.giphy.com/media/10I5e2yNnaozOo/giphy.gif")
            XCTAssertEqual(results[1].mp4URL, "https://media1.giphy.com/media/10I5e2yNnaozOo/giphy.mp4")
            
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
        let searchGIFs = GIFSearchRequest(searchOptions: searchOptions, paginator: paginator)
        switch searchOptions {
        case .Search(let term, let url):
            XCTAssertEqual(searchGIFs.urlRequest.URL?.absoluteString, "\(url)/\(term)/1/100")
        default:
            XCTFail("Test was setup incorrectly, should be searching")
        }
    }
}
