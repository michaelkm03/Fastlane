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

    func testEmptyResult() {
        let result: GIFSearchRequest.ResultType = []
        let operation = GIFSearchOperation(searchTerm: "fun")
        operation.onComplete(result){ }
        
        if let searchResults = operation.results {
            XCTAssertTrue( searchResults.isEmpty)
            XCTAssertNil( operation.next() )
            XCTAssertNil( operation.prev() )
        } else {
            XCTFail("operation.reesults should not be nil")
        }
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
        operation.onComplete(result){ }
        if let searchResults = operation.results as? [GIFSearchResultObject]
            where !searchResults.isEmpty {
                XCTAssertEqual( searchResults.count, 1)
                XCTAssertEqual( searchResults[0].remoteID, "1001" )
                XCTAssertNotNil( operation.next() )
                XCTAssertNil( operation.prev() )
        } else {
            XCTFail("operation.reesults should not be nil or empty.")
        }
    }

    func testOnError() {
        let operation = GIFSearchOperation(searchTerm: "fun")
        
        var completionBlockExecuted = false
        
        operation.onError(NSError(domain: "test", code: 1, userInfo: nil)) {
            completionBlockExecuted = true
        }

        XCTAssertTrue(completionBlockExecuted)
        if let searchResults = operation.results {
            XCTAssertTrue(searchResults.isEmpty)
        } else {
            XCTFail("operation.reesults should not be nil")
        }
    }
}
