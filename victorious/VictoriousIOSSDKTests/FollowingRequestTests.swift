//
//  SubscribedToListRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class SubscribedToListRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FollowersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        do {
            let followingRequest = SubscribedToListRequest(userID: 100)
            let results = try followingRequest.parseResponse(NSURLResponse(), toRequest: followingRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 3)
            XCTAssertEqual(results[0].id, 576)
            XCTAssertEqual(results[0].name, "Ksnd")
            XCTAssertEqual(results[1].id, 1794)
            XCTAssertEqual(results[1].name, "Me!")
            XCTAssertEqual(results[2].id, 2613)
            XCTAssertEqual(results[2].name, "Sebastian")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 102, itemsPerPage: 103)
        let followingRequest = SubscribedToListRequest(userID: 101, paginator: paginator)
        XCTAssertEqual(followingRequest.urlRequest.URL?.absoluteString, "/api/follow/subscribed_to_list/101/102/103")
    }
}
