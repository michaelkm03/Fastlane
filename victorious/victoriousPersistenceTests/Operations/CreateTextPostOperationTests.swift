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

class CreateTextPostOperationTests: XCTestCase {
    
    func testMain() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", backgroundImageURL: nil, backgroundColor: UIColor.blueColor())
        let testExecutor = TestRequestExecutor()
        guard let operation = CreateTextPostOperation(parameters: mockParameters) else {
            XCTFail("Operation Construction should not fail")
            return
        }
        
        operation.requestExecutor = testExecutor
        operation.main()

        XCTAssertEqual(1, testExecutor.executeRequestCallCount)
    }
}
