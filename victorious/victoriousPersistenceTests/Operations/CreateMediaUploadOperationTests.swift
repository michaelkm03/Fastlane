//
//  CreateMediaUploadOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class CreateMediaUploadOperationTests: XCTestCase {
    
    let uploadManager = TestUploadManager()

    func testOperationExecution() {
        let mockParameters = VPublishParameters()
        mockParameters.mediaToUploadURL = NSURL(string: "www.google.com")!
        let operation = CreateMediaUploadOperation(publishParameters: mockParameters, uploadManager: uploadManager) { (results, error) in
        }
        
        operation.start()
        XCTAssertEqual(1, uploadManager.enqueuedTasksCount)
    }

    func testInvalidParameters() {
        let invalidParameters = VPublishParameters()
        let operation = CreateMediaUploadOperation(publishParameters: invalidParameters, uploadManager: uploadManager) { (results, error) in
        }

        operation.start()
        XCTAssertEqual(0, uploadManager.enqueuedTasksCount)
    }
}
