//
//  StandardPaginatorTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class StandardPaginatorTests: XCTestCase {

    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
        let request = NSMutableURLRequest(url: URL(string: "http://www.example.com/api/test")!)
        paginator.addPaginationArgumentsToRequest(request)
        
        let expectedURL = "http://www.example.com/api/test/1/10"
        let actualURL = request.url?.absoluteString
        XCTAssertEqual(expectedURL, actualURL)
    }
    
    func testNextPage() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
        let nextPage = paginator.nextPage(paginator.itemsPerPage)!
        XCTAssertEqual(nextPage.pageNumber, 2)
        XCTAssertEqual(nextPage.itemsPerPage, 10)
    }
    
    func testPageHasNoNextPage() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
        XCTAssertNil( paginator.nextPage(0) )
    }
    
    func testPreviousPage() {
        let paginator = StandardPaginator(pageNumber: 2, itemsPerPage: 10)
        let previousPage = paginator.previousPage()
        XCTAssertEqual(previousPage?.pageNumber, 1)
        XCTAssertEqual(previousPage?.itemsPerPage, 10)
    }
    
    func testFirstPageHasNoPreviousPage() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 10)
        let previousPage = paginator.previousPage()
        XCTAssertNil(previousPage)
    }
}
