//
//  CreatePollOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class CreatePollOperationTests: BaseRequestOperationTestCase {
    
    func testOperationExecution() {
        let mockAnswers = [
            PollAnswer(label: "AAA", mediaURL: NSURL(string: "media_A")!),
            PollAnswer(label: "BBB", mediaURL: NSURL(string: "media_B")!)
        ]
        let mockParameters = PollParameters(name: "mockName", question: "mockQuestion", description: "mockDescription", answers: mockAnswers)
        
        guard let operation = CreatePollOperation(parameters: mockParameters) else {
            XCTFail("Operation Construction should not fail")
            return
        }
        operation.requestExecutor = testRequestExecutor
        
        queueExpectedOperation(operation: operation)
        waitForExpectationsWithTimeout(expectationThreshold) { error in
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
        }
    }
    
    func testInvalidParameters() {
        let invalidAnswers = [
            PollAnswer(label: "AAA", mediaURL: NSURL(string: "media_A")!),
            PollAnswer(label: "BBB", mediaURL: NSURL(string: "media_B")!),
            PollAnswer(label: "CCC", mediaURL: NSURL(string: "media_C")!)
        ]
        
        let invalidParameters = PollParameters(name: "mockName", question: "mockQuestion", description: "mockDescription", answers: invalidAnswers)
        
        let operation: CreatePollOperation? = CreatePollOperation(parameters: invalidParameters)
        XCTAssertNil(operation)
    }
}
