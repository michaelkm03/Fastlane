//
//  RequestOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
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

class MockRequestOperation<T: RequestType>: RequestOperation<T> {
    var onStartCalled: Bool = false
    var onCompleteCalled: Bool = false
    var onErrorCalled: Bool = false

    override init( request: T ) {
        super.init( request: request )
    }
    
    override func onStart( completion:()->() ) {
        self.onStartCalled = true
        completion()
    }
    
    override func onComplete( result: T.ResultType, completion:()->() ) {
        self.onCompleteCalled = true
        completion()
    }
    
    override func onError( error: NSError, completion: ()->() ) {
        self.onErrorCalled = true
        completion()
    }
}

class RequestOperationTests: XCTestCase {
    
    func testBasic() {
        let expectation = self.expectationWithDescription( "testBasic" )
        let operation = MockRequestOperation( request: MockRequest() )
        operation.queue() { error in
            XCTAssert( NSThread.currentThread().isMainThread )
            XCTAssertNil( error )
            XCTAssert( operation.onCompleteCalled )
            XCTAssert( operation.onStartCalled )
            XCTAssertFalse( operation.onErrorCalled )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) { error in }
    }
    
    func testError() {
        let expectation = self.expectationWithDescription( "testError" )
        let operation = MockRequestOperation( request: MockErrorRequest() )
        operation.queue() { error in
            XCTAssert( NSThread.currentThread().isMainThread )
            XCTAssertNotNil( error )
            XCTAssertFalse( operation.onCompleteCalled )
            XCTAssert( operation.onStartCalled )
            XCTAssert( operation.onErrorCalled )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) { error in }
    }
}
