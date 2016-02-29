//
//  UnreadNotificationsCountRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class UnreadNotificationsCountRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("UnreadNotificationsCountResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let notificationCount = UnreadNotificationsCountRequest()
            let count = try notificationCount.parseResponse(NSURLResponse(), toRequest: notificationCount.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(count, 12)
           
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let notificationCount = UnreadNotificationsCountRequest()
        XCTAssertEqual(notificationCount.urlRequest.URL?.absoluteString, "/api/notification/unread_notification_count")
    }
}
