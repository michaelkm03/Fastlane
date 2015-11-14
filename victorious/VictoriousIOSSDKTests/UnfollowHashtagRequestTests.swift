//
//  UnfollowHashtagRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import XCTest

class UnfollowHashtagRequestTests: XCTestCase {
    
    func testRequest() {
        
        let targetHashtag = "surfer"
        
        let unfollowHashtag = UnfollowHashtagRequest(hashtagToUnfollow: targetHashtag)
        let request = unfollowHashtag.urlRequest
        
        XCTAssertEqual(request.URL?.absoluteString, "/api/hashtag/unfollow")
        XCTAssertEqual(request.HTTPMethod, "POST")
        
        guard let bodyData = request.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("hashtag=\(targetHashtag)"))
    }
}
