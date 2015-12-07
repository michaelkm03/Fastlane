//
//  StreamPaginatorTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class StreamPaginatorTests: XCTestCase {
    
    func testRequest() {
        let apiPath = "api/sequence/recent/%%SEQUENCE_ID%%/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
        let paginator = StreamPaginator(apiPath: apiPath, sequenceID: "5", pageNumber: 1, itemsPerPage: 10)!
        XCTAssertEqual( paginator.apiPath, apiPath)
        XCTAssertEqual( paginator.itemsPerPage, 10)
        XCTAssertEqual( paginator.pageNumber, 1)
        XCTAssertEqual( paginator.sequenceID, "5")
        let request = NSMutableURLRequest(URL: NSURL())
        paginator.addPaginationArgumentsToRequest(request)
        let expectedURL = "api/sequence/recent/\(paginator.sequenceID!)/\(paginator.pageNumber)/\(paginator.itemsPerPage)"
        let actualURL = request.URL?.absoluteString
        XCTAssertEqual(expectedURL, actualURL)
    }
    
    func testRequestWithInvalidDependencies() {
        let apiPath = "api/sequence/recent/%%SEQUENCE_ID%%/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
        let paginator = StreamPaginator(apiPath: apiPath)
        XCTAssertNil( paginator,
            "Providing an apiPath that contains %%SEQUENCE_ID%% with no sequenceID value should fail." )
    }
    
    func testRequestWithMinimumDependencies() {
        let apiPath = "api/sequence/recent/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
        let paginator = StreamPaginator(apiPath: apiPath)!
        XCTAssertEqual( paginator.apiPath, apiPath)
        XCTAssertEqual( paginator.itemsPerPage, 15)
        XCTAssertEqual( paginator.pageNumber, 1)
        XCTAssertEqual( paginator.sequenceID, nil)
        let request = NSMutableURLRequest(URL: NSURL())
        paginator.addPaginationArgumentsToRequest(request)
        let expectedURL = "api/sequence/recent/\(paginator.pageNumber)/\(paginator.itemsPerPage)"
        let actualURL = request.URL?.absoluteString
        XCTAssertEqual(expectedURL, actualURL)
    }
    
    func testNextPage() {
        let apiPath = "api/sequence/recent/%%SEQUENCE_ID%%/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
        let paginator =  StreamPaginator(apiPath: apiPath, sequenceID: "5", pageNumber: 1, itemsPerPage: 10)!
        let nextPage = paginator.nextPage(paginator.itemsPerPage)!
        XCTAssertEqual(nextPage.pageNumber, 2)
        XCTAssertEqual(nextPage.itemsPerPage, 10)
    }
    
    func testPageHasNoNextPage() {
        let apiPath = "api/sequence/recent/%%SEQUENCE_ID%%/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
        let paginator =  StreamPaginator(apiPath: apiPath, sequenceID: "5", pageNumber: 1, itemsPerPage: 10)!
        var nextPage = paginator.nextPage(paginator.itemsPerPage-1)
        XCTAssertNil( nextPage )
        
        nextPage = paginator.nextPage(0)
        XCTAssertNil( nextPage )
    }
    
    func testPreviousPage() {
        let apiPath = "api/sequence/recent/%%SEQUENCE_ID%%/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
        let paginator =  StreamPaginator(apiPath: apiPath, sequenceID: "5", pageNumber: 2, itemsPerPage: 10)!
        let previousPage = paginator.previousPage()
        XCTAssertEqual(previousPage?.pageNumber, 1)
        XCTAssertEqual(previousPage?.itemsPerPage, 10)
    }
    
    func testFirstPageHasNoPreviousPage() {
        let apiPath = "api/sequence/recent/%%SEQUENCE_ID%%/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
        let paginator =  StreamPaginator(apiPath: apiPath, sequenceID: "5", pageNumber: 1, itemsPerPage: 10)!
        let previousPage = paginator.previousPage()
        XCTAssertNil(previousPage)
    }
}
