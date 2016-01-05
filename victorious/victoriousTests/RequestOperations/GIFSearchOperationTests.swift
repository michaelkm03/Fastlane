//
//  GIFSearchOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON
import VictoriousIOSSDK
@testable import victorious

class GIFSearchOperationTests: XCTestCase {

    func testEmptyResult() {
        let result: GIFSearchRequest.ResultType = []
        let operation = GIFSearchOperation(searchTerm: "fun")
        operation.onComplete(result){ }
        
        XCTAssertNil( operation.results )
        XCTAssertNil( operation.next() )
        XCTAssertNil( operation.prev() )
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
        if let searchResults = operation.results {
            XCTAssertEqual( searchResults.count, 1)
            XCTAssertEqual( searchResults[0].remoteID(), "1001" )
            XCTAssertNotNil( operation.next() )
            XCTAssertNotNil( operation.prev() )
        } else {
            XCTFail()
        }
    }
}
