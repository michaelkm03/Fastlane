//
//  RequestPasswordResetRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class RequestPasswordResetRequestTests: XCTestCase {
    
    func testRequest() {
        let mockEmail: String = "mock@gmail.com"
        let request = RequestPasswordResetRequest(email: mockEmail)
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/password_reset_request")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("email=\(mockEmail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.vsdk_queryPartAllowedCharacterSet)!)"))
    }
}
