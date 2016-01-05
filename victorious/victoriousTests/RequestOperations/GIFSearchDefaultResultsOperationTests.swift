//
//  GIFSearchDefaultResultsOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON
import VictoriousIOSSDK
@testable import victorious

class GIFSearchDefaultResultsOperationTests: XCTestCase {
    
    func testEmptyResult() {
        let result: TrendingGIFsRequest.ResultType = []
        let operation = GIFSearchDefaultResultsOperation()
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
        let result: TrendingGIFsRequest.ResultType = [ GIFSearchResult(json: mockJSON)! ]
        let operation = GIFSearchDefaultResultsOperation()
        operation.onComplete(result){ }
        if let defaultResults = operation.results {
            XCTAssertEqual(defaultResults.count, 1)
            XCTAssertEqual(defaultResults[0].remoteID(), "1001")
            XCTAssertNotNil( operation.next() )
            XCTAssertNotNil( operation.prev() )
        } else {
            XCTFail()
        }
    }
}
