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
    
    let uploadManager = TestUploadManager()

    func testOperationExecution() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", backgroundImageURL: nil, backgroundColor: UIColor.blueColor())
        guard let operation = CreateTextPostOperation(parameters: mockParameters, previewImage: UIImage(), uploadManager: uploadManager) else {
            XCTFail("Operation Construction should not fail")
            return
        }
        
        operation.start()
        XCTAssertEqual(1, uploadManager.enqueuedTasksCount)
    }

    func testInvalidParameters() {
        let invalidParameters = TextPostParameters(content: "mockTextPostContent", backgroundImageURL: nil, backgroundColor: nil)
        let operation = CreateTextPostOperation(parameters: invalidParameters, previewImage: UIImage(), uploadManager: uploadManager)
        XCTAssertNil(operation)
    }
}
