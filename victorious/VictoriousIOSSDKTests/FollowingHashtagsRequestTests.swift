//
//  FollowingHashtagsRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class FollowingHashtagsRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FollowingHashtagsResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
            let followingHashtags = FollowingHashtagsRequest(paginator: paginator)
            let results = try followingHashtags.parseResponse(NSURLResponse(), toRequest: followingHashtags.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].hashtagID, 191)
            XCTAssertEqual(results[0].tag, "test")
            XCTAssertEqual(results[1].hashtagID, 495)
            XCTAssertEqual(results[1].tag, "surfer")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
        let followingHashtags = FollowingHashtagsRequest(paginator: paginator)
        XCTAssertEqual(followingHashtags.urlRequest.URL?.absoluteString, "/api/hashtag/subscribed_to_list/1/100")
    }
}
