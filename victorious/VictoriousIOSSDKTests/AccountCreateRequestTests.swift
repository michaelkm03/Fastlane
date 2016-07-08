//
//  AccountCreateRequestTests.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class AccountCreateRequestTests: XCTestCase {
    
    func testEmailRequest() {
        let mockEmail = "joe@abc.com"
        let mockPassword = "hunter2"
        let credentials = NewAccountCredentials.EmailPassword(email: mockEmail, password: mockPassword)
        
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let request = accountCreateRequest.urlRequest
        
        XCTAssertEqual(request.URL?.absoluteString, "/api/account/create")
        
        guard let bodyData = request.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("email=\(mockEmail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.vsdk_queryPartAllowedCharacterSet)!)"))
        XCTAssertNotNil(bodyString.rangeOfString("password=\(mockPassword)"))
    }
    
    func testFacebookRequest() {
        let mockToken = "abcxyz"
        let credentials = NewAccountCredentials.Facebook(accessToken: mockToken)
        
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let request = accountCreateRequest.urlRequest
        
        XCTAssertEqual(request.URL?.absoluteString, "/api/account/create/via_facebook_modern")
        
        guard let bodyData = request.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("facebook_access_token=\(mockToken)"))
    }
    
    func testTwitterRequest() {
        let mockToken = "abc"
        let mockSecret = "xyz"
        let mockTwitterID = "31337"
        let credentials = NewAccountCredentials.Twitter(accessToken: mockToken, accessSecret: mockSecret, twitterID: mockTwitterID)
        
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let request = accountCreateRequest.urlRequest
        
        XCTAssertEqual(request.URL?.absoluteString, "/api/account/create/via_twitter_modern")
        
        guard let bodyData = request.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("access_token=\(mockToken)"))
        XCTAssertNotNil(bodyString.rangeOfString("access_secret=\(mockSecret)"))
        XCTAssertNotNil(bodyString.rangeOfString("twitter_id=\(mockTwitterID)"))
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("AccountCreateResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let mockEmail = "joe@abc.com"
        let mockPassword = "hunter2"
        let credentials = NewAccountCredentials.EmailPassword(email: mockEmail, password: mockPassword)
        
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        
        do {
            let response = try accountCreateRequest.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(response.token, "f08745e841c878da64951f7bb3ceb114df27cfda")
            XCTAssertTrue(response.newUser)
            XCTAssertEqual(response.user.id, 1760702)
            XCTAssertEqual(response.user.name, "Joe Victorious")
            XCTAssertEqual(response.user.email, "shsis@sksiis.sndndndh")
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
