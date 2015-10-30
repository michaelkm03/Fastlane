//
//  EndpointRequestTests.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/22/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

private let mockBaseURL = NSURL(string: "https://www.example.com/")!
private let mockRequestURL = NSURL(string: "/abc/123")!
private let mockURLRequest = NSURLRequest(URL: mockRequestURL)

private struct MockEndpoint<T>: Endpoint {
    typealias ResponseParser = (NSURLRequest, NSURLResponse, NSData, JSON) throws -> T
    
    var urlRequest = mockURLRequest
    var mockResponseParser: ResponseParser
    
    func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> T {
        return try mockResponseParser(request, response, responseData, responseJSON)
    }
    
    init(mockResponseParser: ResponseParser) {
        self.mockResponseParser = mockResponseParser
    }
}

private struct MockUserAuthorizationProvider: UserAuthorizationProvider {
    let userID: Int64 = 31337
    let token = "abcdefg"
}

private struct MockClientAuthorizationProvider: ClientAuthorizationProvider {
    let appID = 1
    let deviceID = "57a01bb1-e97d-420e-96d1-b98966328df8"
    let buildNumber = "1234"
}

class EndpointRequestTests: XCTestCase {

    func testBaseURL() {
        var mockEndpoint = MockEndpoint() { (_) -> () in }
        mockEndpoint.urlRequest = NSURLRequest(URL: NSURL(string: "/abc/123")!)
        
        let endpointRequest = EndpointRequest(baseURL: mockBaseURL, endpoint: mockEndpoint, clientAuthorizationProvider: MockClientAuthorizationProvider())
        let actualURLRequest = endpointRequest.urlRequest
        
        XCTAssertEqual(actualURLRequest.URL?.absoluteString, NSURL(string: mockRequestURL.absoluteString, relativeToURL: mockBaseURL)?.absoluteString)
    }
    
    func testNoNeedForBaseURL() {
        var mockEndpoint = MockEndpoint() { (_) -> () in }
        let mockURLString = "https://api2.victorious.com/abc/123"
        mockEndpoint.urlRequest = NSURLRequest(URL: NSURL(string: mockURLString)!)
        
        let endpointRequest = EndpointRequest(baseURL: mockBaseURL, endpoint: mockEndpoint, clientAuthorizationProvider: MockClientAuthorizationProvider())
        let actualURLRequest = endpointRequest.urlRequest
        
        XCTAssertEqual(actualURLRequest.URL?.absoluteString, mockURLString)
    }
    
    func testJSONParsing() {
        let mockJSONDictionary = [ "a": "b", "c": "d" ]
        let mockJSONData = try! NSJSONSerialization.dataWithJSONObject(mockJSONDictionary, options: [])
        
        let mockEndpoint = MockEndpoint() { (_, _, _, json) -> () in
            XCTAssertEqual(json["a"].string, "b")
            XCTAssertEqual(json["c"].string, "d")
        }
        let endpointRequest = EndpointRequest(baseURL: mockBaseURL, endpoint: mockEndpoint, clientAuthorizationProvider: MockClientAuthorizationProvider(), userAuthorizationProvider: MockUserAuthorizationProvider())
        do {
            try endpointRequest.parseResponse(NSURLResponse(), toRequest: mockEndpoint.urlRequest, responseData: mockJSONData)
        }
        catch {
            XCTFail("Sorry, EndpointRequest.parseResponse() should NOT throw here.")
        }
    }
    
    /// Tests that the parseResponse function inside EndpointRequest calls the parseResponse function on Endpoint and passes through the parameters and return value
    func testParseResponseInvocation() {
        let mockURL = NSURL(string: "http://www.test.com/test")!
        let expectedURLRequest = NSURLRequest(URL: mockURL)
        let expectedURLResponse = NSURLResponse(URL: mockURL, MIMEType: "text/plain", expectedContentLength: 100, textEncodingName: "UTF-8")
        let expectedData = "body text".dataUsingEncoding(NSUTF8StringEncoding)!
        let expectedReturnValue = 5
        let mockEndpoint = MockEndpoint() { (urlRequest, urlResponse, data, _) -> Int in
            XCTAssertEqual(expectedURLRequest, urlRequest)
            XCTAssertEqual(expectedURLResponse, urlResponse)
            XCTAssertEqual(expectedData, data)
            return expectedReturnValue
        }
        
        let endpointRequest = EndpointRequest(baseURL: mockBaseURL, endpoint: mockEndpoint, clientAuthorizationProvider: MockClientAuthorizationProvider(), userAuthorizationProvider: MockUserAuthorizationProvider())
        do {
            let actualReturnValue = try endpointRequest.parseResponse(expectedURLResponse, toRequest: expectedURLRequest, responseData: expectedData)
            XCTAssertEqual(actualReturnValue, expectedReturnValue)
        }
        catch {
            XCTFail("Sorry, EndpointRequest.parseResponse() should NOT throw here.")
        }
    }
    
    func testErrorThrownDuringParsing() {
        let expectedError = NSError(domain: "TestError", code: 100, userInfo: nil)
        let mockEndpoint = MockEndpoint() { (urlRequest, urlResponse, data, _) throws -> Int in
            throw expectedError
        }
        
        let endpointRequest = EndpointRequest(baseURL: mockBaseURL, endpoint: mockEndpoint, clientAuthorizationProvider: MockClientAuthorizationProvider())
        do {
            try endpointRequest.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: NSData())
            XCTFail("parseResponse should have thrown")
        }
        catch let actualError {
            XCTAssertEqual(actualError as NSError, expectedError)
        }
    }
    
    func testAuthorizationHeader() {
        let mockEndpoint = MockEndpoint() { (_) -> () in }
        let endpointRequest = EndpointRequest(baseURL: mockBaseURL, endpoint: mockEndpoint, clientAuthorizationProvider: MockClientAuthorizationProvider(), userAuthorizationProvider: MockUserAuthorizationProvider())
        
        let expectedURLRequest = mockEndpoint.urlRequest.mutableCopy() as! NSMutableURLRequest
        expectedURLRequest.vsdk_setAuthorizationHeader(clientAuthorizationProvider: MockClientAuthorizationProvider(), userAuthorizationProvider: MockUserAuthorizationProvider())
        let actualURLRequest = endpointRequest.urlRequest
        
        XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["Authorization"], actualURLRequest.allHTTPHeaderFields?["Authorization"])
        XCTAssertEqual(expectedURLRequest.allHTTPHeaderFields?["User-Agent"], actualURLRequest.allHTTPHeaderFields?["User-Agent"])
    }
}
