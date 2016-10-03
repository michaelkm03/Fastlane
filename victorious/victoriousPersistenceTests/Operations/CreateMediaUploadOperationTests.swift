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
        mockParameters.mediaToUploadURL = URL(string: "www.google.com")!
        
        let expectation = self.expectation(description: "CreateMediaUploadOperation Tests")
        let operation = CreateMediaUploadOperation(apiPath: APIPath(templatePath: ""), publishParameters: mockParameters, uploadManager: uploadManager)!
        
        operation.queue() { _ in
            XCTAssertEqual(1, self.uploadManager.enqueuedTasksCount)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testParameterNoURL() {
        let invalidParameters = VPublishParameters()
        
        let expectation = self.expectation(description: "CreateMediaUploadOperation Tests")
        let operation = CreateMediaUploadOperation(apiPath: APIPath(templatePath: ""), publishParameters: invalidParameters, uploadManager: uploadManager)!
        
        operation.queue() { _ in
            XCTAssertEqual(0, self.uploadManager.enqueuedTasksCount)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)

    }
    
    func testGifIDOnly() {
        let mockParameters = VPublishParameters()
        mockParameters.isGIF = true
        mockParameters.assetRemoteId = "ABCDEF"
        
        let expectation = self.expectation(description: "CreateMediaUploadOperation Tests")
        let operation = CreateMediaUploadOperation(apiPath: APIPath(templatePath: ""), publishParameters: mockParameters, uploadManager: uploadManager)!
        
        operation.queue() { _ in
            XCTAssertEqual(1, self.uploadManager.enqueuedTasksCount)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
