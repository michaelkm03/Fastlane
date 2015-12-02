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
}
