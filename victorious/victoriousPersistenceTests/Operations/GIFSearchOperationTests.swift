//
//  GIFSearchOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class GIFSearchOperationTests: XCTestCase {
    let searchOptions = AssetSearchOptions.search(term: "fun", url: "testURL")
    
    func testEmptyResult() {
        let operation = GIFSearchOperation(searchOptions: searchOptions)
        
        let testRequestExecutor = TestRequestExecutor(result: [GIFSearchResult]())
        operation.requestExecutor = testRequestExecutor
        
        let expectation = self.expectation(description: "GIFSearchOperation")
        operation.queue { result in
            expectation.fulfill()
            
            if let searchResults = result.output {
                XCTAssertTrue( searchResults.isEmpty)
                XCTAssertNil( operation.next() )
                XCTAssertNil( operation.prev() )
            } else {
                XCTFail("operation.reesults should not be nil")
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testValidResult() {
        let mockJSON: JSON = [
            "gif_url": "www.gif.com",
            "mp4_url": "www.mp4.com",
            "width": 101,
            "height": 102,
            "thumbnail_still": "www.still.com",
            "remote_id": "1001"
        ]
        let result: GIFSearchRequest.ResultType = [ GIFSearchResult(json: mockJSON)! ]
        
        let operation = GIFSearchOperation(searchOptions: searchOptions)
        
        let testRequestExecutor = TestRequestExecutor(result: result)
        operation.requestExecutor = testRequestExecutor
        
        let expectation = self.expectation(description: "GIFSearchOperation")
        operation.queue { result in
            expectation.fulfill()
            XCTAssertNil(result.error)
            if let searchResults = result.output as? [GIFSearchResultObject] , !searchResults.isEmpty {
                XCTAssertEqual( searchResults.count, 1)
                XCTAssertEqual( searchResults[0].remoteID, "1001" )
                XCTAssertNotNil( operation.next() )
                XCTAssertNil( operation.prev() )
            } else {
                XCTFail("operation.reesults should not be nil or empty.")
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testOnError() {
        let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
        
        let operation = GIFSearchOperation(searchOptions: searchOptions)
        
        let testRequestExecutor = TestRequestExecutor(error: expectedError)
        operation.requestExecutor = testRequestExecutor
        
        let expectation = self.expectation(description: "GIFSearchOperation")
        operation.queue { result in
            expectation.fulfill()
            XCTAssertEqual(result.error as? NSError, expectedError)
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
