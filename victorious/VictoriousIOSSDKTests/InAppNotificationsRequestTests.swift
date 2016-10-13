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
        guard let mockResponseDataURL = Bundle(for: type(of: self)).url(forResource: "NotificationsResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let notificationRequest = InAppNotificationsRequest(apiPath: APIPath(templatePath: "https://www.abc.com"))!
            let results = try notificationRequest.parseResponse(URLResponse(), toRequest: notificationRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results[0].subject, "Ryan Higa sent you a message")
            XCTAssertEqual(results[0].deeplink, "officialryanhiga://inbox/1379901")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let request1 = InAppNotificationsRequest(apiPath: APIPath(templatePath: ""))
        XCTAssertNil(request1)
        
        let request2 = InAppNotificationsRequest(apiPath: APIPath(templatePath: "/api/notification/notifications_list"))
        XCTAssertEqual(request2?.urlRequest.url?.absoluteString, "/api/notification/notifications_list")
    }
}
