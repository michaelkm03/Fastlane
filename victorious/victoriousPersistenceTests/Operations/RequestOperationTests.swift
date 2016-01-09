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

class RequestOperationTests: XCTestCase {
    
    var requestOperation: RequestOperation!
    var requestOperationRequestExecutor: RequestExecutorType!

    override func setUp() {
        requestOperation = RequestOperation()
        requestOperationRequestExecutor = MainRequestExecutor(persistentStore: MainPersistentStore())
    }
    
    func testBasic() {
        let expectation = self.expectationWithDescription("testBasic")
        
        let request = MockRequest()
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            self.requestOperation.requestExecutor.executeRequest( request,
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
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            self.requestOperation.requestExecutor.executeRequest( request,
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
