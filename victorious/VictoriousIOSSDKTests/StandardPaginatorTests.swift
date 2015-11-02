//
//  StandardPaginatorTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class StandardPaginatorTests: XCTestCase {

    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
        let request = paginator.paginatedRequestWithRequest(NSURLRequest(URL: NSURL(string: "http://www.example.com/api/test")!))
        
        let expectedURL = "http://www.example.com/api/test/1/10"
        let actualURL = request.URL?.absoluteString
        XCTAssertEqual(expectedURL, actualURL)
    }
    
    func testNextPageContinuation() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
        let json = [ "page_number": 1, "total_pages": 100 ]
        let results = paginator.parsePageInformationFromResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: NSData(), responseJSON: JSON(json))
        
        let nextPaginator = StandardPaginator(continuation: results.nextPage!)
        let request = nextPaginator.paginatedRequestWithRequest(NSURLRequest(URL: NSURL(string: "http://www.google.com/api")!))
        
        let expectedURL = "http://www.google.com/api/2/10"
        let actualURL = request.URL?.absoluteString
        XCTAssertEqual(expectedURL, actualURL)
    }
    
    func testLastPageHasNoNextPage() {
        let paginator = StandardPaginator(pageNumber: 2, itemsPerPage: 10)
        let json = [ "page_number": 2, "total_pages": 2 ]
        let results = paginator.parsePageInformationFromResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: NSData(), responseJSON: JSON(json))
        XCTAssertNil(results.nextPage)
    }
    
    func testPreviousPageContinuation() {
        let paginator = StandardPaginator(pageNumber: 2, itemsPerPage: 10)
        let json = [ "page_number": 2, "total_pages": 100 ]
        let results = paginator.parsePageInformationFromResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: NSData(), responseJSON: JSON(json))
        
        let nextPaginator = StandardPaginator(continuation: results.previousPage!)
        let request = nextPaginator.paginatedRequestWithRequest(NSURLRequest(URL: NSURL(string: "http://www.askjeeves.com/api")!))
        
        let expectedURL = "http://www.askjeeves.com/api/1/10"
        let actualURL = request.URL?.absoluteString
        XCTAssertEqual(expectedURL, actualURL)
    }
    
    func testFirstPageHasNoPreviousPage() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
        let results = paginator.parsePageInformationFromResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: NSData(), responseJSON: JSON(NSNull()))
        XCTAssertNil(results.previousPage)
    }
}
