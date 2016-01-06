//
//  UnfollowUserRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class UnfollowUserRequestTests: XCTestCase {
    
    func testRequest() {
        
        let targetUserID: Int = 5107
        
        let unfollowUser = UnfollowUserRequest(userToUnfollowID: targetUserID, screenName: "profile")
        let request = unfollowUser.urlRequest
        
        XCTAssertEqual(request.URL?.absoluteString, "/api/follow/remove")
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
