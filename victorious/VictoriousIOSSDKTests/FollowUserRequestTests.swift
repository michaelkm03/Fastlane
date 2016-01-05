//
//  FollowUserRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class FollowUserRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FollowUserResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let followUser = FollowUserRequest(userID: 5107, screenName: "profile")
            try followUser.parseResponse(NSURLResponse(), toRequest: followUser.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        
        let targetUserID: Int64 = 5107
        
        let followUser = FollowUserRequest(userID: targetUserID, screenName: "profile")
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
}
