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
        let result: GIFSearchRequest.ResultType = ([], nil, nil)
        let operation = GIFSearchOperation(searchText: "fun")
        operation.onComplete(result){ }
        
        XCTAssertTrue(operation.searchResults.isEmpty)
        XCTAssertNil(operation.nextPageOperation)
        XCTAssertNil(operation.previousPageOperation)
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
        let result: GIFSearchRequest.ResultType = ([GIFSearchResult(json: mockJSON)!], GIFSearchRequest(searchTerm: "next"), GIFSearchRequest(searchTerm: "Prev"))
        let operation = GIFSearchOperation(searchText: "fun")
        operation.onComplete(result){ }
        
        XCTAssertEqual(operation.searchResults.count, 1)
        XCTAssertEqual(operation.searchResults[0].remoteID, "1001")
        XCTAssertNotNil(operation.nextPageOperation)
        XCTAssertNotNil(operation.previousPageOperation)
    }
}
