//
//  FollowHashtagRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class FollowHashtagRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FollowHashtagResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let followHashtag = FollowHashtagRequest(hashtag: "surfer")
            try followHashtag.parseResponse(NSURLResponse(), toRequest: followHashtag.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        
        let targetHashtag = "surfer"
        
        let followHashtag = FollowHashtagRequest(hashtag: targetHashtag)
        let request = followHashtag.urlRequest
        
        XCTAssertEqual(request.URL?.absoluteString, "/api/hashtag/follow")
        XCTAssertEqual(request.HTTPMethod, "POST")
        
        guard let bodyData = request.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("hashtag=\(targetHashtag)"))
    }
}
