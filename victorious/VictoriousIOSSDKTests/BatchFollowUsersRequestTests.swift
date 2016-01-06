//
//  BatchFollowUsersRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class BatchFollowUsersRequestTests: XCTestCase {
    
    func testRequest() {
        let userIDsToFollow: [Int] = [266, 3787]
        let batchFollowRequest = BatchFollowUsersRequest(usersToFollow: userIDsToFollow)
        
        let request = batchFollowRequest.urlRequest
        
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