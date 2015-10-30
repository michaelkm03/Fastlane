//
//  RequestTests.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/12/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Nocilla
import VictoriousIOSSDK
import XCTest

private let mockRequestURL = NSURL(string: "http://www.example.com")!
private let mockURLRequest = NSURLRequest(URL: mockRequestURL)

class MockRequest: Request {
    typealias ResponseParser = (NSURLRequest, NSURLResponse, NSData) throws -> Int
    
    var urlRequest = mockURLRequest
    var mockResponseParser: ResponseParser
    
    func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData) throws -> Int {
        return try mockResponseParser(request, response, responseData)
    }
    
    init(mockResponseParser: ResponseParser) {
        self.mockResponseParser = mockResponseParser
    }
}

class RequestTests: XCTestCase {
    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }
    
    override func tearDown() {
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
        super.tearDown()
    }
    
    func testSuccessfulExecution() {
        let expectedResponse = "good"
        stubRequest("GET", mockRequestURL.absoluteString).andReturn(200).withBody(expectedResponse)
        
        let expectedResult = 2
        let parseResponseExpectation = expectationWithDescription("parseResponse")
        let mockRequest = MockRequest { (urlRequest, response, responseData) -> Int in
            XCTAssertEqual(urlRequest, mockURLRequest)
            XCTAssertEqual(responseData, expectedResponse.dataUsingEncoding(NSUTF8StringEncoding))
            parseResponseExpectation.fulfill()
            return expectedResult
        }
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute { (actualResult, error) in
            XCTAssertNil(error)
            XCTAssertEqual(actualResult, expectedResult)
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testNetworkFailure() {
        let expectedError = NSError(domain: "Really Bad Error", code: 99, userInfo: nil)
        stubRequest("GET", mockRequestURL.absoluteString).andFailWithError(expectedError)
        
        let mockRequest = MockRequest { (_) -> Int in
            return 2
        }
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute { (result, actualError) in
            XCTAssertEqual(actualError as? NSError, expectedError)
            XCTAssertNil(result)
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testParsingFailure() {
        let expectedResponse = "bad"
        stubRequest("GET", mockRequestURL.absoluteString).andReturn(200).withBody(expectedResponse)
        
        let expectedError = NSError(domain: "Really Bad Error", code: 100, userInfo: nil)
        let parseResponseExpectation = expectationWithDescription("parseResponse")
        let mockRequest = MockRequest { (_) -> Int in
            parseResponseExpectation.fulfill()
            throw expectedError
        }
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute { (actualResult, actualError) in
            XCTAssertNil(actualResult)
            XCTAssertEqual(actualError as? NSError, expectedError)
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    /// Request.parseResponse() has a parameter, "request", which is documented to be "The original NSURLRequest".
    /// This function tests that assertion by sneaking in an NSMutableURLRequest and mutating it at an opportune time.
    func testRequestIsOriginal() {
        stubRequest("GET", mockRequestURL.absoluteString).andReturn(200).withBody("body")
        
        let mutableURLRequest = mockURLRequest.mutableCopy() as! NSMutableURLRequest
        let parseResponseExpectation = expectationWithDescription("parseResponse")
        let mockRequest = MockRequest { (urlRequest, response, responseData) -> Int in
            mutableURLRequest.URL = NSURL(string: "http://www.google.com/") // mutate OUR copy of the URL request.
            XCTAssertEqual(urlRequest, mockURLRequest) // assert that the previous line didn't mutate the "urlRequest" argument
            parseResponseExpectation.fulfill()
            return 3
        }
        mockRequest.urlRequest = mutableURLRequest // sneak in a mutable URL request...
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute { (actualResult, error) in
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
