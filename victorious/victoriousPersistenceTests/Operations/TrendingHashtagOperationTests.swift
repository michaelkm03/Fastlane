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

class TrendingHashtagOperationTests: BaseFetcherOperationTestCase {
    
    func test() {
        let tagString = "testHashtag"
        let hashtag = Hashtag(tag: tagString)
        
        let operation = TrendingHashtagOperation(url: NSURL())
        testRequestExecutor = TestRequestExecutor(result:[hashtag])
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("PasswordRequestResetOperation")
        operation.queue() { results, error, cancelled in
            
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
            XCTAssertEqual(operation.results?.count, 1)
            
            guard let firstResult = operation.results?.first as? HashtagSearchResultObject else {
                XCTFail("first object in results should be an instance of HashtagSearchResultObject")
                return
            }
            let sourceResult = firstResult.sourceResult
            XCTAssertEqual(sourceResult.tag, tagString)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
