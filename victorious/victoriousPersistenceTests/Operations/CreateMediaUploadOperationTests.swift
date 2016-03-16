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
    let operationQueue = NSOperationQueue()
    
    func testOperationExecution() {
        let mockParameters = VPublishParameters()
        mockParameters.mediaToUploadURL = NSURL(string: "www.google.com")!
        let operation = CreateMediaUploadOperation(publishParameters: mockParameters, uploadManager: uploadManager) { error in
        }
        
        let expectation = expectationWithDescription("CreateMediaUploadOperation Tests")
        operation.completionBlock = {
            XCTAssertEqual(1, self.uploadManager.enqueuedTasksCount)
            expectation.fulfill()
        }
        
        operationQueue.addOperation(operation)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
