//
//  DevicePreferencesRequestTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class DevicePreferencesRequestTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRequest() {
        let request = DevicePreferencesRequest()
        let urlRequest = request.urlRequest
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/device/preferences")
    }
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("DevicePreferencesResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = DevicePreferencesRequest()
            let result = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssert(result.contains(.CreatorPost))
            XCTAssertFalse(result.contains(.FollowPost))
            XCTAssertFalse(result.contains(.CommentPost))
            XCTAssert(result.contains(.PrivateMessage))
            XCTAssert(result.contains(.NewFollower))
            XCTAssertFalse(result.contains(.TagPost))
            XCTAssert(result.contains(.Mention))
            XCTAssertFalse(result.contains(.LikePost))
            XCTAssert(result.contains(.Announcement))
            XCTAssertFalse(result.contains(.NextDay))
            XCTAssertFalse(result.contains(.LapsedUser))
            XCTAssertFalse(result.contains(.EmotiveBallistic))
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testAllEnabled() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("DevicePreferencesAllOnResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = DevicePreferencesRequest()
            let result = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssert(result.contains(.CreatorPost))
            XCTAssert(result.contains(.FollowPost))
            XCTAssert(result.contains(.CommentPost))
            XCTAssert(result.contains(.PrivateMessage))
            XCTAssert(result.contains(.NewFollower))
            XCTAssert(result.contains(.TagPost))
            XCTAssert(result.contains(.Mention))
            XCTAssert(result.contains(.LikePost))
            XCTAssert(result.contains(.Announcement))
            XCTAssert(result.contains(.NextDay))
            XCTAssert(result.contains(.LapsedUser))
            XCTAssert(result.contains(.EmotiveBallistic))
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
