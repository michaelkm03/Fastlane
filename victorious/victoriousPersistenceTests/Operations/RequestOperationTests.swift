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

class RequestOperationTests: XCTestCase {
    
    var requestOperation: RequestOperation!

    override func setUp() {
        requestOperation = RequestOperation()
    }
    
    func testBasic() {
        let expectation = self.expectationWithDescription("testBasic")
        
        let request = MockRequest()
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            self.requestOperation.executeRequest( request,
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
            self.requestOperation.executeRequest( request,
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
