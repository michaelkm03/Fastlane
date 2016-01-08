//
//  FollowersListRequestTest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class FollowersListRequestTest: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FollowersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        do {
            let followersRequest = FollowersListRequest(userID: 100)
            let results = try followersRequest.parseResponse(NSURLResponse(), toRequest: followersRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 3)
            XCTAssertEqual(results[0].userID, 576)
            XCTAssertEqual(results[0].name, "Ksnd")
            XCTAssertEqual(results[1].userID, 1794)
            XCTAssertEqual(results[1].name, "Me!")
            XCTAssertEqual(results[2].userID, 2613)
            XCTAssertEqual(results[2].name, "Sebastian")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 102, itemsPerPage: 103)
        let followersRequest = FollowersListRequest(userID: 101, paginator: paginator)
        XCTAssertEqual(followersRequest.urlRequest.URL?.absoluteString, "/api/follow/followers_list/101/102/103")
    }
}