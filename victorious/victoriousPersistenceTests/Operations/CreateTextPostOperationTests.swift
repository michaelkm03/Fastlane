//
//  CreateTextPostOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class CreateTextPostOperationTests: BaseRequestOperationTestCase {
    
    func testOperationExecution() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", backgroundImageURL: nil, backgroundColor: UIColor.blueColor())
        guard let operation = CreateTextPostOperation(parameters: mockParameters) else {
            XCTFail("Operation Construction should not fail")
            return
        }
        operation.requestExecutor = self.testRequestExecutor
        
        queueExpectedOperation(operation: operation)
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }

    func testInvalidParameters() {
        let invalidParameters = TextPostParameters(content: "mockTextPostContent", backgroundImageURL: nil, backgroundColor: nil)
        let operation = CreateTextPostOperation(parameters: invalidParameters)
        XCTAssertNil(operation)
    }
}
