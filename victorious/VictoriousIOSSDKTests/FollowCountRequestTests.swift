//
//  FollowCountRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class FollowCountRequestTests: XCTestCase {
    
    func testRequest() {
        let mockUserID: Int64 = 101
        let followCountRequest = FollowCountRequest(userID: mockUserID)
        XCTAssertEqual(followCountRequest.urlRequest.URL?.absoluteString, "/api/follow/counts/101")
    }
    
    func testValidResponseParsing() {
        let mockJSON = JSON(["payload": ["subscribed_to": "102", "followers": "103"]])
        do {
            let followCountRequest = FollowCountRequest(userID: 101)
            let followCount = try followCountRequest.parseResponse(NSURLResponse(), toRequest: followCountRequest.urlRequest, responseData: NSData(), responseJSON: mockJSON)
    
            XCTAssertEqual(followCount.followingCount, 102)
            XCTAssertEqual(followCount.followersCount, 103)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testInvalidResponseParsing() {
        let invalidMockJSONArray = [
            JSON(["subscribed_to": false, "followers": "103"]),
            JSON(["subscribed_to": "102", "followers": "Roses are red"]),
            JSON(["subscribed_to": "102"]),
            JSON(["followers": "103"]),
            JSON([])
        ]
        
        let followCountRequest = FollowCountRequest(userID: 101)
        for invalidMockJSON in invalidMockJSONArray {
            AssertThrowsSpecific(try followCountRequest.parseResponse(NSURLResponse(), toRequest: followCountRequest.urlRequest, responseData: NSData(), responseJSON: invalidMockJSON), ResponseParsingError())
        }
    }
}