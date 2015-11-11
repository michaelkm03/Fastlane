//
//  NotificationsRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class NotificationsRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("NotificationsResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let notifications = NotificationsRequest(pageNumber: 1, itemsPerPage: 100)
            let (results, nextPage, previousPage) = try notifications.parseResponse(NSURLResponse(), toRequest: notifications.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results[0].subject, "Ryan Higa sent you a message")
            XCTAssertEqual(results[0].deeplink, "officialryanhiga://inbox/1379901")
            
            XCTAssertNil(previousPage, "There should be no page before page 1")
            XCTAssertNotNil(nextPage, "Next page should not be nil")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let notifications = NotificationsRequest(pageNumber: 1, itemsPerPage: 100)
        XCTAssertEqual(notifications.urlRequest.URL?.absoluteString, "/api/notification/notifications_list/1/100")
    }
}

