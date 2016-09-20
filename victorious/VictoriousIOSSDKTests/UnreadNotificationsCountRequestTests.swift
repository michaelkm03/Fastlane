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
    private static let apiPath = APIPath(templatePath: "http://api.getvictorious.com//api/notification/unread_notification_count")

    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("UnreadNotificationsCountResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let notificationCount = UnreadNotificationsCountRequest(apiPath: UnreadNotificationsCountRequestTests.apiPath)!
            let count = try notificationCount.parseResponse(NSURLResponse(), toRequest: notificationCount.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(count, 12)
           
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let notificationCount = UnreadNotificationsCountRequest(apiPath: UnreadNotificationsCountRequestTests.apiPath)!
        XCTAssertEqual(notificationCount.urlRequest.URL?.absoluteString, "http://api.getvictorious.com//api/notification/unread_notification_count")
    }
}
