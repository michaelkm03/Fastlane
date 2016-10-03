//
//  PasswordResetRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class PasswordResetRequestTests: XCTestCase {
    
    func testPasswordResetRequest() {
        let mockNewPassword = "MockNewPassword"
        let mockUserToken = "MockUserToken"
        let mockDeviceToken = "MockDeviceToken"
        
        let request = PasswordResetRequest(newPassword: mockNewPassword, userToken: mockUserToken, deviceToken: mockDeviceToken)
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/password_reset")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: String.Encoding.utf8)!
        
        XCTAssertNotNil(bodyString.rangeOfString("new_password=\(mockNewPassword)"))
        XCTAssertNotNil(bodyString.rangeOfString("user_token=\(mockUserToken)"))
        XCTAssertNotNil(bodyString.rangeOfString("device_token=\(mockDeviceToken)"))
    }
    
    func testValidateTokenRequest() {
        let expectedEmptyPassword = ""
        let mockUserToken = "MockUserToken"
        let mockDeviceToken = "MockDeviceToken"
        
        let request = PasswordResetRequest(userToken: mockUserToken, deviceToken: mockDeviceToken)
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/password_reset")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: String.Encoding.utf8)!
        
        XCTAssertNotNil(bodyString.rangeOfString("new_password=\(expectedEmptyPassword)"))
        XCTAssertNotNil(bodyString.rangeOfString("user_token=\(mockUserToken)"))
        XCTAssertNotNil(bodyString.rangeOfString("device_token=\(mockDeviceToken)"))
    }
}
