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

class GIFSearchOperationTests: BaseFetcherOperationTestCase {

    func testEmptyResult() {
        let operation = GIFSearchOperation(searchTerm: "fun")
        operation.persistentStore = testStore
        
        testRequestExecutor = TestRequestExecutor(result: [GIFSearchResult]())
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("GIFSearchOperation")
        operation.queue() { results, error in
            expectation.fulfill()
            
            if let searchResults = results {
                XCTAssertTrue( searchResults.isEmpty)
                XCTAssertNil( operation.next() )
                XCTAssertNil( operation.prev() )
            } else {
                XCTFail("operation.reesults should not be nil")
            }
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
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
        
        let operation = GIFSearchOperation(searchTerm: "fun")
        operation.persistentStore = testStore
        
        testRequestExecutor = TestRequestExecutor(result: result)
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("GIFSearchOperation")
        operation.queue() { results, error in
            expectation.fulfill()
            XCTAssertNil(error)
            if let searchResults = results as? [GIFSearchResultObject] where !searchResults.isEmpty {
                XCTAssertEqual( searchResults.count, 1)
                XCTAssertEqual( searchResults[0].remoteID, "1001" )
                XCTAssertNotNil( operation.next() )
                XCTAssertNil( operation.prev() )
            } else {
                XCTFail("operation.reesults should not be nil or empty.")
            }
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
    }

    func testOnError() {
        let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
        
        let operation = GIFSearchOperation(searchTerm: "fun")
        operation.persistentStore = testStore
        
        testRequestExecutor = TestRequestExecutor(error: expectedError)
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("GIFSearchOperation")
        operation.queue() { results, error in
            expectation.fulfill()
            XCTAssertEqual( error, expectedError )
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler:nil)
    }
}
