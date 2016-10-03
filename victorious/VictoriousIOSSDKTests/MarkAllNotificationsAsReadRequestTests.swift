//
//  MarkAllNotificationsAsReadRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class MarkAllNotificationsAsReadRequestTests: XCTestCase {
    func testRequest() {
        let request = MarkAllNotificationsAsReadRequest()
        XCTAssertEqual(request.urlRequest.url?.absoluteString, "/api/notification/mark_all_notifications_read")
        XCTAssertEqual(request.urlRequest.HTTPMethod, "POST")
    }
}
