//
//  MainRequestExecutorTests.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON
@testable import victorious

struct MockRequest: RequestType {
    let urlRequest = NSURLRequest( URL: NSURL(string: "http://www.google.com" )! )
    func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Bool {
        return true
    }
}

struct MockErrorRequest: RequestType {
    let urlRequest = NSURLRequest( URL: NSURL(string: "http://www.google.com" )! )
    func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Bool {
        throw APIError( localizedDescription: "MockError", code: 999)
    }
}

class MockRequestOperation: RequestOperation {
    var validRequest: MockRequest
    init(request: MockRequest) {
        validRequest = request
    }
    
    override func main() {
        requestExecutor.executeRequest( validRequest, onComplete: nil, onError: nil )
    }
}

class MockErrorRequestOperation: RequestOperation {
    var errorRequest: MockErrorRequest
    init(request: MockErrorRequest) {
        errorRequest = request
    }
    
    override func main() {
        requestExecutor.executeRequest( errorRequest, onComplete: nil, onError: nil )
    }
}

class MainRequestExecutorTests: XCTestCase {
    
    func testOnComplete() {
        let expectation = self.expectationWithDescription("testBasic")
        let requestOperation = MockRequestOperation(request: MockRequest())
        
        requestOperation.queueOn(requestOperation.defaultQueue) { error in
            expectation.fulfill()
            XCTAssertNil(error)
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testOnError() {
        let expectation = self.expectationWithDescription("testError")
        let errorOperation = MockErrorRequestOperation(request: MockErrorRequest())
        
        errorOperation.queueOn(errorOperation.defaultQueue) { error in
            expectation.fulfill()
            XCTAssertNotNil(error)
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
