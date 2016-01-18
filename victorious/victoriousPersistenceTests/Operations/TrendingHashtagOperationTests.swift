//
//  TrendingHashtagOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class TrendingHashtagOperationTests: BaseRequestOperationTestCase {
    
    func testRequestExecution() {
        let operation = TrendingHashtagOperation()
        operation.requestExecutor = testRequestExecutor
        
        queueExpectedOperation(operation: operation)

        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    func testResults() {
        let operation = TrendingHashtagOperation()
        
        let tagString = "testHashtag"
        let hashtag = Hashtag(tag: tagString)
        
        operation.onComplete([hashtag]) { }

        guard let firstResult = operation.results?.first else {
            XCTFail("first object in results should be an instance of HashtagSearchResultObject")
            return
        }
        
        let sourceResult = firstResult.sourceResult
        XCTAssertEqual(sourceResult.tag, tagString)
    }
}
