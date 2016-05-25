//
//  LoginRequestTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class LoginRequestTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRequest() {
        let mockEmail = "joe@abc.com"
        let mockPassword = "hunter2"
        let loginRequest = LoginRequest(email: mockEmail, password: mockPassword)
        let request = loginRequest.urlRequest
        
        XCTAssertEqual(request.URL?.absoluteString, "/api/login")
        
        guard let bodyData = request.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("email=\(mockEmail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.vsdk_queryPartAllowedCharacterSet)!)"))
        XCTAssertNotNil(bodyString.rangeOfString("password=\(mockPassword)"))
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("LoginResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let loginRequest = LoginRequest(email: "joe@example.com", password: "hunter2")
        
        do {
            let response = try loginRequest.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(response.token, "a787304ffd2cfcbc67edf0f628a030abdcf1808d")
            XCTAssertEqual(response.user.id, 156)
            XCTAssertEqual(response.user.name, "Joe")
            XCTAssertEqual(response.user.email, "joe@example.com")
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
