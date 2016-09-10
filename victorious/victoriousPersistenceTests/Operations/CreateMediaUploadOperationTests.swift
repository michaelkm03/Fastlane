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
        
        let expectation = expectationWithDescription("CreateMediaUploadOperation Tests")
        let operation = CreateMediaUploadOperation(publishParameters: mockParameters, uploadManager: uploadManager, apiPath: APIPath(templatePath: ""))
        
        operation.queue() { _ in
            XCTAssertEqual(1, self.uploadManager.enqueuedTasksCount)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testParameterNoURL() {
        let invalidParameters = VPublishParameters()
        
        let expectation = expectationWithDescription("CreateMediaUploadOperation Tests")
        let operation = CreateMediaUploadOperation(publishParameters: invalidParameters, uploadManager: uploadManager, apiPath: APIPath(templatePath: ""))
        
        operation.queue() { _ in
            XCTAssertEqual(0, self.uploadManager.enqueuedTasksCount)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)

    }
    
    func testGifIDOnly() {
        let mockParameters = VPublishParameters()
        mockParameters.isGIF = true
        mockParameters.assetRemoteId = "ABCDEF"
        
        let expectation = expectationWithDescription("CreateMediaUploadOperation Tests")
        let operation = CreateMediaUploadOperation(publishParameters: mockParameters, uploadManager: uploadManager, apiPath: APIPath(templatePath: ""))
        
        operation.queue() { _ in
            XCTAssertEqual(1, self.uploadManager.enqueuedTasksCount)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
