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
    typealias ResponseParser = (URLRequest, URLResponse, Data, JSON) throws -> T
    
    fileprivate var _urlRequest: NSMutableURLRequest /// Using a private, mutable stored property and a public computed property is necessary to expose certain bugs in the execute() implementation
    var urlRequest: URLRequest {
        return _urlRequest.copy() as! URLRequest
    }
    
    let mockResponseParser: ResponseParser
    
    func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> T {
        return try mockResponseParser(request, response, responseData, responseJSON)
    }
    
    init(urlRequest: NSMutableURLRequest, responseParser: @escaping ResponseParser) {
        self._urlRequest = urlRequest
        self.mockResponseParser = responseParser
    }

    convenience init(requestURL: URL, responseParser: @escaping ResponseParser) {
        self.init(urlRequest: NSMutableURLRequest(url: requestURL), responseParser: responseParser)
    }
}

class RequestTypeTests: XCTestCase {

    fileprivate let mockAuthenticationContext =  AuthenticationContext(userID: 31337, token: "abcdefg")
    fileprivate let mockRequestContext = RequestContext(appID: 1, deviceID: "57a01bb1-e97d-420e-96d1-b98966328df8", firstInstallDeviceID: "ed8ac5f2-d3dd-4ca2-a471-9c6e74f3c0d9", buildNumber: "1234", appVersion: "1.0", experimentIDs: [1], sessionID: "e384f969-a6c6-4b85-b8f2-ae7ef4c810f1")
    
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
        stubRequest("GET", "http://www.example.com/" as LSMatcheable!).andReturn(200)?.withBody(expectedResponse)
        
        let expectedResult = 2
        let expectedURLRequest = NSMutableURLRequest(url: URL(string: "http://www.example.com/")!)
        expectedURLRequest.setValue("canary", forHTTPHeaderField: "Coal-Mine")
        
        let parseResponseExpectation = expectation(description: "parseResponse")
        let mockRequest = MockRequest(urlRequest: expectedURLRequest) { (actualURLRequest, response, responseData, responseJSON) -> Int in
            XCTAssertEqual(actualURLRequest.url, expectedURLRequest.url)
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["Coal-Mine"], "canary")
            XCTAssertEqual(responseData, expectedResponse.data(using: String.Encoding.utf8))
            XCTAssertEqual(responseJSON.null, NSNull())
            parseResponseExpectation.fulfill()
            return expectedResult
        }
        
        let callbackExpectation = expectation(description: "callback")
        mockRequest.execute(baseURL: URL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (actualResult, error) in
            XCTAssertNil(error)
            XCTAssertEqual(actualResult, expectedResult)
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testNetworkFailure() {
        let mockRequestURL = URL(string: "http://www.failure.com")!
        let expectedError = NSError(domain: "Really Bad Error", code: 99, userInfo: nil)
        stubRequest("GET", mockRequestURL.absoluteString as LSMatcheable!).andFailWithError(expectedError)
        
        let mockRequest = MockRequest(requestURL: mockRequestURL) { (_) -> Int in
            return 2
        }
        
        let callbackExpectation = expectation(description: "callback")
        mockRequest.execute(baseURL: URL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (result, actualError) in
            XCTAssertEqual(actualError as? NSError, expectedError)
            XCTAssertNil(result)
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testParsingFailure() {
        let mockRequestURL = URL(string: "http://www.cantparse.net")!
        let expectedResponse = "bad"
        stubRequest("GET", mockRequestURL.absoluteString as LSMatcheable!).andReturn(200)?.withBody(expectedResponse)
        
        let expectedError = NSError(domain: "Really Bad Error", code: 100, userInfo: nil)
        let parseResponseExpectation = expectation(description: "parseResponse")
        let mockRequest = MockRequest(requestURL: mockRequestURL) { (_) -> Int in
            parseResponseExpectation.fulfill()
            throw expectedError
        }
        
        let callbackExpectation = expectation(description: "callback")
        mockRequest.execute(baseURL: URL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (actualResult, actualError) in
            XCTAssertNil(actualResult)
            XCTAssertEqual(actualError as? NSError, expectedError)
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testProperApplicationOfBaseURL() {
        let callbackExpectation = expectation(description: "callback")
        let request = MockRequest(requestURL: URL(string: "/abc/123")!) { (_, _, responseData: Data, _) -> () in
            let responseString = String(data: responseData, encoding: String.Encoding.utf8)
            XCTAssertEqual(responseString, "test")
            callbackExpectation.fulfill()
        }
        stubRequest("GET", "http://api.example.com/abc/123" as LSMatcheable!).andReturn(200)?.withBody("test")
        
        request.execute(baseURL: URL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testBaseURLNotAppliedWhenNotNecessary() {
        let mockURLString = "https://api2.victorious.com/abc/123"
        let callbackExpectation = expectation(description: "callback")
        let request = MockRequest(requestURL: URL(string: mockURLString)!) { (_, _, responseData: Data, _) -> () in
            let responseString = String(data: responseData, encoding: String.Encoding.utf8)
            XCTAssertEqual(responseString, "test")
            callbackExpectation.fulfill()
        }
        stubRequest("GET", mockURLString as LSMatcheable!).andReturn(200)?.withBody("test")
        
        request.execute(baseURL: URL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testJSONParsing() {
        let mockJSONDictionary = [ "a": "b", "c": "d" ]
        let mockJSONData = try! JSONSerialization.data(withJSONObject: mockJSONDictionary, options: [])
        
        let callbackExpectation = expectation(description: "callback")
        let request = MockRequest(requestURL: URL(string: "/api/test")!) { (_, _, _, json) -> () in
            XCTAssertEqual(json["a"].string, "b")
            XCTAssertEqual(json["c"].string, "d")
            callbackExpectation.fulfill()
        }
        stubRequest("GET", "http://api.example.com/api/test" as LSMatcheable!).andReturn(200)?.withHeader("Content-Type", "application/json")?.withBody(mockJSONData)
        
        request.execute(baseURL: URL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAuthenticationHeader() {
        let expectedURLRequest = NSMutableURLRequest(url: URL(string: "http://api.example.com/api/test2")!)
        expectedURLRequest.vsdk_setAuthorizationHeader(requestContext: mockRequestContext, authenticationContext: mockAuthenticationContext)

        let callbackExpectation = expectation(description: "callback")
        let request = MockRequest(requestURL: URL(string: "/api/test2")!) { (actualURLRequest: URLRequest, _, _, _) -> () in
            XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["Authorization"], actualURLRequest.allHTTPHeaderFields?["Authorization"])
            XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["User-Agent"], actualURLRequest.allHTTPHeaderFields?["User-Agent"])
            callbackExpectation.fulfill()
        }
        
        stubRequest("GET", "http://api.example.com/api/test2" as LSMatcheable!).andReturn(200)
        
        request.execute(baseURL: URL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: mockAuthenticationContext)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAuthenticationHeaderWithNoAuthenticationContext() {
        let expectedURLRequest = NSMutableURLRequest(url: URL(string: "http://api.example.com/api/test3")!)
        expectedURLRequest.vsdk_setAuthorizationHeader(requestContext: mockRequestContext)
        
        let callbackExpectation = expectation(description: "callback")
        let request = MockRequest(requestURL: URL(string: "/api/test3")!) { (actualURLRequest: URLRequest, _, _, _) -> () in
            XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["Authorization"], actualURLRequest.allHTTPHeaderFields?["Authorization"])
            XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["User-Agent"], actualURLRequest.allHTTPHeaderFields?["User-Agent"])
            callbackExpectation.fulfill()
        }
        
        stubRequest("GET", "http://api.example.com/api/test3" as LSMatcheable!).andReturn(200)
        
        request.execute(baseURL: URL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testOtherHeaders() {
        
        let callbackExpectation = expectation(description: "callback")
        let request = MockRequest(requestURL: URL(string: "/api/test4")!) { (actualURLRequest: URLRequest, _, _, _) in
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-Platform"], "iOS")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-OS-Version"], UIDevice.current.systemVersion)
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-App-ID"], "1")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-App-Version"], "1.0")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-Session-ID"], "e384f969-a6c6-4b85-b8f2-ae7ef4c810f1")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-Experiment-IDs"], "1")
            XCTAssertEqual(actualURLRequest.allHTTPHeaderFields?["X-Client-Install-Device-ID"], "ed8ac5f2-d3dd-4ca2-a471-9c6e74f3c0d9")
            callbackExpectation.fulfill()
        }
        
        stubRequest("GET", "http://api.example.com/api/test4" as LSMatcheable!).andReturn(200)
        
        request.execute(baseURL: URL(string: "http://api.example.com/")!, requestContext: mockRequestContext, authenticationContext: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    /// RequestType.parseResponse() has a parameter, "request", which is documented to be "The NSURLRequest that was sent to the server".
    /// This function tests that assertion by mutating the request at an opportune time.
    func testRequestIsOriginal() {
        let mockURLRequest = NSMutableURLRequest(url: URL(string: "http://www.sneaky-mutation.org")!)
        stubRequest("GET", mockURLRequest.url!.absoluteString as LSMatcheable!).andReturn(200)?.withBody("body")
        
        let parseResponseExpectation = expectation(description: "parseResponse")
        let mockRequest = MockRequest(urlRequest: mockURLRequest) { (urlRequest, _, _, _) -> Int in
            mockURLRequest.url = NSURL(string: "http://www.google.com/") as URL? // mutate OUR copy of the URL request.
            XCTAssertEqual(urlRequest.url?.absoluteString, "http://www.sneaky-mutation.org") // assert that the previous line didn't mutate the "urlRequest" argument
            parseResponseExpectation.fulfill()
            return 3
        }
        
        let callbackExpectation = expectation(description: "callback")
        mockRequest.execute(baseURL: URL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (actualResult, error) in
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAPIErrorParsing() {
        let errorCode = 89732
        let errorMessage = "TEST ERROR"
        let mockRequestURL = URL(string: "http://api.example.com/api/test")!
        let mockJSONDictionary = [ "message": errorMessage, "error": errorCode ] as [String : Any]
        let mockJSONData = try! JSONSerialization.data(withJSONObject: mockJSONDictionary, options: [])
        stubRequest("GET", mockRequestURL.absoluteString as LSMatcheable!).andReturn(200)?.withHeader("Content-Type", "application/json")?.withBody(mockJSONData)
        let mockRequest = MockRequest(requestURL: mockRequestURL) { (_) -> Int in
            return 2
        }
        
        let callbackExpectation = expectation(description: "callback")
        mockRequest.execute(baseURL: URL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (result, actualError) in
            guard let apiError = actualError as? APIError else {
                XCTFail( "Expecting a valid error" )
                return
            }
            XCTAssertEqual(apiError.localizedDescription, errorMessage)
            XCTAssertEqual(apiError.code, errorCode)
            
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAPIErrorParsingNoError() {
        let errorCode = 0
        let errorMessage = ""
        let mockRequestURL = URL(string: "http://api.example.com/api/test")!
        let mockJSONDictionary = [ "message": errorMessage, "error": errorCode ] as [String : Any]
        let mockJSONData = try! JSONSerialization.data(withJSONObject: mockJSONDictionary, options: [])
        stubRequest("GET", mockRequestURL.absoluteString as LSMatcheable!).andReturn(200)?.withHeader("Content-Type", "application/json")?.withBody(mockJSONData)
        let mockRequest = MockRequest(requestURL: mockRequestURL) { (_) -> Int in
            return 2
        }
        
        let callbackExpectation = expectation(description: "callback")
        mockRequest.execute(baseURL: URL(string: "http://this.doesnt.matter/")!, requestContext: mockRequestContext, authenticationContext: nil) { (result, actualError) in
            XCTAssertNil( actualError )
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
