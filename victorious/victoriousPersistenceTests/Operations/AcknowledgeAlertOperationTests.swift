//
//  AcknowledgeAlertOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import victorious

class AcknowledgeAlertOperationTests: BaseRequestOperationTests {

    var testRequestExecutor: TestRequestExecutor!
    var operation: AcknowledgeAlertOperation!
    let alertID = 99
    
    override func setUp() {
        super.setUp()
        operation = AcknowledgeAlertOperation(queryString: "test")
        operation.requestExecutor = testRequestExecutor
    }
    
    func testExample() {
        queueExpectedOperation(operation: operation)
        
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }
}
