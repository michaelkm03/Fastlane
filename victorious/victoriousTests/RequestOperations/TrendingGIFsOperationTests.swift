//
//  TrendingGIFsOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON
import VictoriousIOSSDK
@testable import victorious

class TrendingGIFsOperationTests: XCTestCase {
    
    func testEmptyResult() {
        let result: TrendingGIFsRequest.ResultType = ([], nil, nil)
        let operation = TrendingGIFsOperation()
        operation.onComplete(result){ }
        
        XCTAssertTrue(operation.trendingGIFsResults.isEmpty)
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
        let result: TrendingGIFsRequest.ResultType = ([GIFSearchResult(json: mockJSON)!], TrendingGIFsRequest(), TrendingGIFsRequest())
        let operation = TrendingGIFsOperation()
        operation.onComplete(result){ }
        
        XCTAssertEqual(operation.trendingGIFsResults.count, 1)
        XCTAssertEqual(operation.trendingGIFsResults[0].remoteID, "1001")
        XCTAssertNotNil(operation.nextPageOperation)
        XCTAssertNotNil(operation.previousPageOperation)
    }
}
