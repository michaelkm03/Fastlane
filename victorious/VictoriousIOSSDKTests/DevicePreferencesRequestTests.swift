//
//  DevicePreferencesRequestTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

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
    
    func testChangeRequest() {
        let request = DevicePreferencesRequest(preferences: [.CreatorPost: true, .NewFollower: false])
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.HTTPMethod, "POST")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("notification_creator_post=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_new_follower=0"))
    }
    
    func testChangeRequestAllOff() {
        let request = DevicePreferencesRequest(preferences: [.CreatorPost: false,
            .FollowPost: false,
            .CommentPost: false,
            .PrivateMessage: false,
            .NewFollower: false,
            .TagPost: false,
            .Mention: false,
            .LikePost: false,
            .Announcement: false,
            .NextDay: false,
            .LapsedUser: false,
            .EmotiveBallistic: false])
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.HTTPMethod, "POST")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("notification_creator_post=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_follow_post=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_comment_post=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_private_message=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_new_follower=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_tag_post=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_mention=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_like_post=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_announcement=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_next_day=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_lapsed_user=0"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_emotive_ballistic=0"))
    }
    
    func testChangeRequestAllOn() {
        let request = DevicePreferencesRequest(preferences: [.CreatorPost: true,
            .FollowPost: true,
            .CommentPost: true,
            .PrivateMessage: true,
            .NewFollower: true,
            .TagPost: true,
            .Mention: true,
            .LikePost: true,
            .Announcement: true,
            .NextDay: true,
            .LapsedUser: true,
            .EmotiveBallistic: true])
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.HTTPMethod, "POST")
        
        guard let bodyData = urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("notification_creator_post=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_follow_post=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_comment_post=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_private_message=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_new_follower=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_tag_post=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_mention=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_like_post=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_announcement=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_next_day=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_lapsed_user=1"))
        XCTAssertNotNil(bodyString.rangeOfString("notification_emotive_ballistic=1"))
    }
}
