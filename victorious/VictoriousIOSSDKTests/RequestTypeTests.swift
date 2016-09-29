//
//  RequestTypeTests.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/22/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Nocilla
import UIKit
import VictoriousIOSSDK
import XCTest

private class MockRequest<T>: RequestType {
    typealias ResponseParser = (NSURLRequest, NSURLResponse, NSData, JSON) throws -> T
    
    private var _urlRequest: NSMutableURLRequest /// Using a private, mutable stored property and a public computed property is necessary to expose certain bugs in the execute() implementation
    var urlRequest: NSURLRequest {
        return _urlRequest.copy() as! NSURLRequest
    }
    
    let mockResponseParser: ResponseParser
    
    func parseResponse(_ response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> T {
        return try mockResponseParser(request, response, responseData, responseJSON)
    }
    
    init(urlRequest: NSMutableURLRequest, responseParser: ResponseParser) {
        self._urlRequest = urlRequest
        self.mockResponseParser = responseParser
    }

    convenience init(requestURL: NSURL, responseParser: ResponseParser) {
        self.init(urlRequest: NSMutableURLRequest(URL: requestURL), responseParser: responseParser)
    }
}

class RequestTypeTests: XCTestCase {

    private let mockAuthenticationContext =  AuthenticationContext(userID: 31337, token: "abcdefg")
    private let mockRequestContext = RequestContext(appID: 1, deviceID: "57a01bb1-e97d-420e-96d1-b98966328df8", firstInstallDeviceID: "ed8ac5f2-d3dd-4ca2-a471-9c6e74f3c0d9", buildNumber: "1234", appVersion: "1.0", sessionID: "e384f969-a6c6-4b85-b8f2-ae7ef4c810f1", experimentIDs: [1])
    
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
        stubRequest("GET", "http://www.example.com/").andReturn(200).withBody(expectedResponse)
        
        let expectedResult = 2
        let expectedURLRequest = NSMutableURLRequest(URL: NSURL(string: "http://www.example.com/")!)
        expectedURLRequest.setValue("canary", forHTTPHeaderField: "Coal-Mine")
        
        let parseResponseExpectation = expectationWithDescription("parseResponse")
        let mockRequest = MockRequest(urlRequest: expectedURLRequest) { (actualURLRequest, response, responseData, responseJSON) -> Int in
            XCTAssertEqual(actualURLRequest.URL, expectedURLRequest.URL)
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["Coal-Mine"], "canary")
            XCTAssertEqual(responseData, expectedResponse.dataUsingEncoding(NSUTF8StringEncoding))
            XCTAssertEqual(responseJSON.null, NSNull())
            parseResponseExpectation.fulfill()
            return expectedResult
        }
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute(baseURL: NSURL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (actualResult, error) in
            XCTAssertNil(error)
            XCTAssertEqual(actualResult, expectedResult)
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testNetworkFailure() {
        let mockRequestURL = NSURL(string: "http://www.failure.com")!
        let expectedError = NSError(domain: "Really Bad Error", code: 99, userInfo: nil)
        stubRequest("GET", mockRequestURL.absoluteString).andFailWithError(expectedError)
        
        let mockRequest = MockRequest(requestURL: mockRequestURL) { (_) -> Int in
            return 2
        }
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute(baseURL: NSURL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (result, actualError) in
            XCTAssertEqual(actualError as? NSError, expectedError)
            XCTAssertNil(result)
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testParsingFailure() {
        let mockRequestURL = NSURL(string: "http://www.cantparse.net")!
        let expectedResponse = "bad"
        stubRequest("GET", mockRequestURL.absoluteString).andReturn(200).withBody(expectedResponse)
        
        let expectedError = NSError(domain: "Really Bad Error", code: 100, userInfo: nil)
        let parseResponseExpectation = expectationWithDescription("parseResponse")
        let mockRequest = MockRequest(requestURL: mockRequestURL) { (_) -> Int in
            parseResponseExpectation.fulfill()
            throw expectedError
        }
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute(baseURL: NSURL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (actualResult, actualError) in
            XCTAssertNil(actualResult)
            XCTAssertEqual(actualError as? NSError, expectedError)
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testProperApplicationOfBaseURL() {
        let callbackExpectation = expectationWithDescription("callback")
        let request = MockRequest(requestURL: NSURL(string: "/abc/123")!) { (_, _, responseData: NSData, _) -> () in
            let responseString = String(data: responseData, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(responseString, "test")
            callbackExpectation.fulfill()
        }
        stubRequest("GET", "http://api.example.com/abc/123").andReturn(200).withBody("test")
        
        request.execute(baseURL: NSURL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testBaseURLNotAppliedWhenNotNecessary() {
        let mockURLString = "https://api2.victorious.com/abc/123"
        let callbackExpectation = expectationWithDescription("callback")
        let request = MockRequest(requestURL: NSURL(string: mockURLString)!) { (_, _, responseData: NSData, _) -> () in
            let responseString = String(data: responseData, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(responseString, "test")
            callbackExpectation.fulfill()
        }
        stubRequest("GET", mockURLString).andReturn(200).withBody("test")
        
        request.execute(baseURL: NSURL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testJSONParsing() {
        let mockJSONDictionary = [ "a": "b", "c": "d" ]
        let mockJSONData = try! NSJSONSerialization.dataWithJSONObject(mockJSONDictionary, options: [])
        
        let callbackExpectation = expectationWithDescription("callback")
        let request = MockRequest(requestURL: NSURL(string: "/api/test")!) { (_, _, _, json) -> () in
            XCTAssertEqual(json["a"].string, "b")
            XCTAssertEqual(json["c"].string, "d")
            callbackExpectation.fulfill()
        }
        stubRequest("GET", "http://api.example.com/api/test").andReturn(200).withHeader("Content-Type", "application/json").withBody(mockJSONData)
        
        request.execute(baseURL: NSURL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAuthenticationHeader() {
        let expectedURLRequest = NSMutableURLRequest(URL: NSURL(string: "http://api.example.com/api/test2")!)
        expectedURLRequest.vsdk_setAuthorizationHeader(requestContext: mockRequestContext, authenticationContext: mockAuthenticationContext)

        let callbackExpectation = expectationWithDescription("callback")
        let request = MockRequest(requestURL: NSURL(string: "/api/test2")!) { (actualURLRequest: NSURLRequest, _, _, _) -> () in
            XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["Authorization"], actualURLRequest.allHTTPHeaderFields?["Authorization"])
            XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["User-Agent"], actualURLRequest.allHTTPHeaderFields?["User-Agent"])
            callbackExpectation.fulfill()
        }
        
        stubRequest("GET", "http://api.example.com/api/test2").andReturn(200)
        
        request.execute(baseURL: NSURL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: mockAuthenticationContext)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAuthenticationHeaderWithNoAuthenticationContext() {
        let expectedURLRequest = NSMutableURLRequest(URL: NSURL(string: "http://api.example.com/api/test3")!)
        expectedURLRequest.vsdk_setAuthorizationHeader(requestContext: mockRequestContext)
        
        let callbackExpectation = expectationWithDescription("callback")
        let request = MockRequest(requestURL: NSURL(string: "/api/test3")!) { (actualURLRequest: NSURLRequest, _, _, _) -> () in
            XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["Authorization"], actualURLRequest.allHTTPHeaderFields?["Authorization"])
            XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["User-Agent"], actualURLRequest.allHTTPHeaderFields?["User-Agent"])
            callbackExpectation.fulfill()
        }
        
        stubRequest("GET", "http://api.example.com/api/test3").andReturn(200)
        
        request.execute(baseURL: NSURL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testOtherHeaders() {
        
        let callbackExpectation = expectationWithDescription("callback")
        let request = MockRequest(requestURL: NSURL(string: "/api/test4")!) { (actualURLRequest: NSURLRequest, _, _, _) in
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-Platform"], "iOS")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-OS-Version"], UIDevice.currentDevice().systemVersion)
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-App-ID"], "1")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-App-Version"], "1.0")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-Session-ID"], "e384f969-a6c6-4b85-b8f2-ae7ef4c810f1")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-Experiment-IDs"], "1")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-Install-Device-ID"], "ed8ac5f2-d3dd-4ca2-a471-9c6e74f3c0d9")
            callbackExpectation.fulfill()
        }
        
        stubRequest("GET", "http://api.example.com/api/test4").andReturn(200)
        
        request.execute(baseURL: NSURL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    /// RequestType.parseResponse() has a parameter, "request", which is documented to be "The NSURLRequest that was sent to the server".
    /// This function tests that assertion by mutating the request at an opportune time.
    func testRequestIsOriginal() {
        let mockURLRequest = NSMutableURLRequest(URL: NSURL(string: "http://www.sneaky-mutation.org")!)
        stubRequest("GET", mockURLRequest.URL!.absoluteString).andReturn(200).withBody("body")
        
        let parseResponseExpectation = expectationWithDescription("parseResponse")
        let mockRequest = MockRequest(urlRequest: mockURLRequest) { (urlRequest, _, _, _) -> Int in
            mockURLRequest.URL = NSURL(string: "http://www.google.com/") // mutate OUR copy of the URL request.
            XCTAssertEqual(urlRequest.URL?.absoluteString, "http://www.sneaky-mutation.org") // assert that the previous line didn't mutate the "urlRequest" argument
            parseResponseExpectation.fulfill()
            return 3
        }
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute(baseURL: NSURL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (actualResult, error) in
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAPIErrorParsing() {
        let errorCode = 89732
        let errorMessage = "TEST ERROR"
        let mockRequestURL = NSURL(string: "http://api.example.com/api/test")!
        let mockJSONDictionary = [ "message": errorMessage, "error": errorCode ]
        let mockJSONData = try! NSJSONSerialization.dataWithJSONObject(mockJSONDictionary, options: [])
        stubRequest("GET", mockRequestURL.absoluteString).andReturn(200).withHeader("Content-Type", "application/json").withBody(mockJSONData)
        let mockRequest = MockRequest(requestURL: mockRequestURL) { (_) -> Int in
            return 2
        }
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute(baseURL: NSURL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (result, actualError) in
            guard let apiError = actualError as? APIError else {
                XCTFail( "Expecting a valid error" )
                return
            }
            XCTAssertEqual(apiError.localizedDescription, errorMessage)
            XCTAssertEqual(apiError.code, errorCode)
            
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAPIErrorParsingNoError() {
        let errorCode = 0
        let errorMessage = ""
        let mockRequestURL = NSURL(string: "http://api.example.com/api/test")!
        let mockJSONDictionary = [ "message": errorMessage, "error": errorCode ]
        let mockJSONData = try! NSJSONSerialization.dataWithJSONObject(mockJSONDictionary, options: [])
        stubRequest("GET", mockRequestURL.absoluteString).andReturn(200).withHeader("Content-Type", "application/json").withBody(mockJSONData)
        let mockRequest = MockRequest(requestURL: mockRequestURL) { (_) -> Int in
            return 2
        }
        
        let callbackExpectation = expectationWithDescription("callback")
        mockRequest.execute(baseURL: NSURL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (result, actualError) in
            XCTAssertNil( actualError )
            callbackExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
