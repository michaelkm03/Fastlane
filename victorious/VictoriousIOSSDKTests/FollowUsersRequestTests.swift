//
//  FollowUsersRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class FollowUsersRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FollowUserResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let followUser = FollowUsersRequest(userIDs: [5107], sourceScreenName: "profile")
            try followUser.parseResponse(NSURLResponse(), toRequest: followUser.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testSingleUser() {
        
        let targetUserID: Int = 5107
        
        let followUser = FollowUsersRequest(userIDs: [targetUserID], sourceScreenName: "profile")
        let request = followUser.urlRequest
        
        XCTAssertEqual(request.URL?.absoluteString, "/api/follow/add")
        XCTAssertEqual(request.HTTPMethod, "POST")
        
        guard let bodyData = request.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("source=profile"))
        XCTAssertNotNil(bodyString.rangeOfString("target_user_id=\(targetUserID)"))
    }
    
    func testMultipleUsers() {
        
        let userIDsToFollow: [Int] = [266, 3787]
        let followRequest = FollowUsersRequest(userIDs: userIDsToFollow, sourceScreenName: "")
        
        let request = followRequest.urlRequest
        
        XCTAssertEqual(request.URL?.absoluteString, "/api/follow/batchadd")
        XCTAssertEqual(request.HTTPMethod, "POST")
        
        guard let bodyData = request.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("target_user_ids[]=\(userIDsToFollow[0])"))
        XCTAssertNotNil(bodyString.rangeOfString("target_user_ids[]=\(userIDsToFollow[1])"))
    }
}
