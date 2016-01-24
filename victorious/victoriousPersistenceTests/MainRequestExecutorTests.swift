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
    
    func testCopmletion() {
        let expectation = self.expectationWithDescription("testCopmletion")
        let request = MockRequest()
        let url = request.urlRequest.URL?.absoluteString

        stubRequest("GET", url)

        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            self.requestExecutor.executeRequest( request,
                onComplete: { (result, completion:()->() ) in
                    completion()
                    expectation.fulfill()
                },
                onError: { (error, completion:()->() ) in
                    XCTFail( "Should not be called" )
                }
            )
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testError() {
        let expectation = self.expectationWithDescription("testError")
        let request = MockErrorRequest()
        let url = request.urlRequest.URL?.absoluteString
        
        stubRequest("GET", url)
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            self.requestExecutor.executeRequest( request,
                onComplete: { (result, completion:()->() ) in
                    XCTFail( "Should not be called" )
                },
                onError: { (error, completion:()->() ) in
                    completion()
                    expectation.fulfill()
                }
            )
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
