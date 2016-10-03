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
    
    func testUsernameRequest() {
        let mockUsername = "joe@abc.com"
        let mockPassword = "hunter2"
        let credentials = NewAccountCredentials.UsernamePassword(username: mockUsername, password: mockPassword)
        
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let request = accountCreateRequest.urlRequest
        
        XCTAssertEqual(request.url?.absoluteString, "/api/account/create")
        
        guard let bodyData = request.httpBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: String.Encoding.utf8)!
        
        XCTAssertNotNil(bodyString.range(of: "email=\(mockUsername.addingPercentEncoding(withAllowedCharacters: (CharacterSet.vsdk_queryPartAllowedCharacterSet)!))"))
        XCTAssertNotNil(bodyString.range(of: "password=\(mockPassword)"))
    }
    
    func testFacebookRequest() {
        let mockToken = "abcxyz"
        let credentials = NewAccountCredentials.Facebook(accessToken: mockToken)
        
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        let request = accountCreateRequest.urlRequest
        
        XCTAssertEqual(request.url?.absoluteString, "/api/account/create/via_facebook_modern")
        
        guard let bodyData = request.httpBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: String.Encoding.utf8)!
        
        XCTAssertNotNil(bodyString.range(of: "facebook_access_token=\(mockToken)"))
    }
    
    func testResponseParsing() {
        guard let mockUserDataURL = Bundle(for: type(of: self)).url(forResource: "AccountCreateResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let mockUsername = "joe@abc.com"
        let mockPassword = "hunter2"
        let credentials = NewAccountCredentials.UsernamePassword(username: mockUsername, password: mockPassword)
        
        let accountCreateRequest = AccountCreateRequest(credentials: credentials)
        
        do {
            let response = try accountCreateRequest.parseResponse(URLResponse(), toRequest: URLRequest(url: URL(string: "foo")!), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(response.token, "f08745e841c878da64951f7bb3ceb114df27cfda")
            XCTAssertTrue(response.newUser)
            XCTAssertEqual(response.user.id, 1760702)
            XCTAssertEqual(response.user.displayName, "Joe Victorious")
            XCTAssertEqual(response.user.username, "shsis@sksiis.sndndndh")
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
