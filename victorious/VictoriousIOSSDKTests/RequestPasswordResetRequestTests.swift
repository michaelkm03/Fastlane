//
//  RequestPasswordResetRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class RequestPasswordResetRequestTests: XCTestCase {
    
    let mockEmail: String = "mock@gmail.com"
    
    func testRequest() {
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
    
    func testParseResponse() {
        let mockDeviceToken = "MockDeviceToken"
        let mockJSON = JSON( [ "payload": ["device_token": mockDeviceToken] ] )
        
        do {
            let request = RequestPasswordResetRequest(email: mockEmail)
            let results = try request.parseResponse(NSURLResponse(), toRequest: request.urlRequest, responseData: NSData(), responseJSON: mockJSON)
            
            XCTAssertEqual(results, "MockDeviceToken")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
