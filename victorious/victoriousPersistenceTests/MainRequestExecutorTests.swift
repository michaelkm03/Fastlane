//
//  MainRequestExecutorTests.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious
import Nocilla

class MainRequestExecutorTests: XCTestCase {
    
    lazy var requestExecutor: RequestExecutorType = MainRequestExecutor()

    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }

    override func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }
    
    func testCompletion() {
        let expectation = self.expectation(description: "testCopmletion")
        let request = MockRequest()
        let url = request.urlRequest.url?.absoluteString

        stubRequest("GET", url as NSString?)

        DispatchQueue.global().async {
            self.requestExecutor.executeRequest( request,
                onComplete: { result in
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail( "Should not be called" )
                }
            )
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testError() {
        let expectation = self.expectation(description:"testError")
        let request = MockErrorRequest()
        let url = request.urlRequest.url?.absoluteString
        
        stubRequest("GET", url as NSString?)
        
        DispatchQueue.global().async {
            self.requestExecutor.executeRequest( request,
                onComplete: { result in
                    XCTFail( "Should not be called" )
                },
                onError: { error in
                    expectation.fulfill()
                }
            )
        }
        waitForExpectations(timeout:2, handler: nil)
    }
    
    func testCancelled() {
        let expectation = self.expectation(description:"testError")
        let request = MockRequest()
        let url = request.urlRequest.url?.absoluteString
        
        stubRequest("GET", url as NSString?)
        
        self.requestExecutor.cancelled = true
        DispatchQueue.global().async {
            self.requestExecutor.executeRequest( request,
                onComplete: { result in
                    XCTFail( "Should not be called" )
                },
                onError: { error in
                    XCTFail( "Should not be called" )
                }
            )
        }
        dispatch_after(1.0) {
            expectation.fulfill()
        }
        waitForExpectations(timeout:2.0, handler: nil)
    }
    
    func testErrorWithErrorHandlers() {
        let expectation = self.expectation(description:"testError")
        let request = MockErrorRequest(code: 999)
        let url = request.urlRequest.url?.absoluteString
        
        stubRequest("GET", url as NSString?)
        
        let errorHandler1 = MockErrorHandler(code: 999)
        let errorHandler2 = MockErrorHandler(code: 401)
        
        self.requestExecutor.errorHandlers.append( errorHandler1 )
        self.requestExecutor.errorHandlers.append( errorHandler2 )
        
        DispatchQueue.global().async {
            self.requestExecutor.executeRequest( request,
                onComplete: { result in
                    XCTFail( "Should not be called" )
                },
                onError: { error in
                    XCTAssertEqual( errorHandler1.errorsHandled.count, 1 )
                    XCTAssertEqual( errorHandler2.errorsHandled.count, 0 )
                    expectation.fulfill()
                }
            )
        }
        waitForExpectations(timeout:2, handler: nil)
    }
}
