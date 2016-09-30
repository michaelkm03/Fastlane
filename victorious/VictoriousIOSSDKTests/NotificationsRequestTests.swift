//
//  InAppNotificationsRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class InAppNotificationsRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: type(of: self)).URLForResource("NotificationsResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
            let notifications = InAppNotificationsRequest(paginator: paginator)
            let results = try notifications.parseResponse(NSURLResponse(), toRequest: notifications.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results[0].subject, "Ryan Higa sent you a message")
            XCTAssertEqual(results[0].deeplink, "officialryanhiga://inbox/1379901")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
        let notifications = InAppNotificationsRequest(paginator: paginator)
        XCTAssertEqual(notifications.urlRequest.URL?.absoluteString, "/api/notification/notifications_list/1/100")
    }
}
