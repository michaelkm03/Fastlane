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

class CreatePollOperationTests: XCTestCase {
    
    func testMain() {
        let mockAnswers = [
            PollAnswer(label: "AAA", mediaURL: NSURL(string: "media_A")!),
            PollAnswer(label: "BBB", mediaURL: NSURL(string: "media_B")!)
        ]
        let mockParameters = PollParameters(name: "mockName", question: "mockQuestion", description: "mockDescription", answers: mockAnswers)
        let testExecutor = TestRequestExecutor()
        
        guard let operation = CreatePollOperation(parameters: mockParameters) else {
            XCTFail("Operation Construction should not fail")
            return
        }
        
        operation.requestExecutor = testExecutor
        operation.main()
        
        XCTAssertEqual(1, testExecutor.executeRequestCallCount)
    }
    
    func testInvalidParameters() {
        let mockAnswers = [
            PollAnswer(label: "AAA", mediaURL: NSURL(string: "media_A")!),
            PollAnswer(label: "BBB", mediaURL: NSURL(string: "media_B")!),
            PollAnswer(label: "CCC", mediaURL: NSURL(string: "media_C")!)
        ]
        
        let mockParameters = PollParameters(name: "mockName", question: "mockQuestion", description: "mockDescription", answers: mockAnswers)
        
        let operation: CreatePollOperation? = CreatePollOperation(parameters: mockParameters)
        XCTAssertNil(operation)
    }
}
