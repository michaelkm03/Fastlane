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
        XCTAssertEqual(urlRequest.url?.absoluteString, "/api/device/register_push_id")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: String.Encoding.utf8)!
        
        XCTAssertNotNil(bodyString.range(of: "push_id=\(mockPushID)"))
    }
}
