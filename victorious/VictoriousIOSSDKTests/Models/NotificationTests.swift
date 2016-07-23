//
//  NotificationTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class NotificationTests: XCTestCase {
    
    func testJSONParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("Notification", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        guard let notification = Notification(json: JSON(data: mockData)) else {
            XCTFail("User initializer failed")
            return
        }
        XCTAssertEqual(notification.body, "Thanks for creating a profile! Now I know who you are. Go meet other lamps and post your own stuff!")
        
        let dateFormatter = NSDateFormatter.vsdk_defaultDateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        XCTAssertEqual(notification.createdAt, dateFormatter.dateFromString("2015-11-11 19:00:33"))
        
        XCTAssertEqual(notification.deeplink, "officialryanhiga://inbox/1379901")
        XCTAssertEqual(notification.imageURL, "https://d36dd6wez3mcdh.cloudfront.net/6b867733e89c20227cf45eeff891e9ec/80x80.jpg")
        XCTAssertEqual(notification.isRead, true)
        XCTAssertEqual(notification.type, "private_message")
        XCTAssertEqual(notification.updatedAt, dateFormatter.dateFromString("2015-11-11 19:00:33"))
        XCTAssertEqual(notification.subject, "Ryan Higa sent you a message")
        XCTAssertEqual(notification.user.displayName, "Ryan Higa")
    }
}
