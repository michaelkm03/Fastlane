//
//  RegisterPushNotificationRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class RegisterPushNotificationRequestTests: XCTestCase {
    
    func testRequest() {
        let mockPushID = "mockPushNotificationID"
        let request = RegisterPushNotificationRequest(pushNotificationID: mockPushID)
        let urlRequest = request.urlRequest
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/device/register_push_id")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("push_id=\(mockPushID)"))
    }
}
