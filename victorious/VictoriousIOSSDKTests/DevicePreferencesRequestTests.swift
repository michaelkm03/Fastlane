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
        XCTAssertEqual(urlRequest.url?.absoluteString, "/api/device/preferences")
    }
    
    func testResponseParsing() {
        guard let mockResponseDataURL = Bundle(for: type(of: self)).url(forResource: "DevicePreferencesResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = DevicePreferencesRequest()
            let result = try request.parseResponse(URLResponse(), toRequest: URLRequest(url: URL(string: "foo")!), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssert(result.contains(.creatorPost))
            XCTAssertFalse(result.contains(.followPost))
            XCTAssertFalse(result.contains(.commentPost))
            XCTAssert(result.contains(.privateMessage))
            XCTAssert(result.contains(.newFollower))
            XCTAssertFalse(result.contains(.tagPost))
            XCTAssert(result.contains(.mention))
            XCTAssertFalse(result.contains(.likePost))
            XCTAssert(result.contains(.announcement))
            XCTAssertFalse(result.contains(.nextDay))
            XCTAssertFalse(result.contains(.lapsedUser))
            XCTAssertFalse(result.contains(.emotiveBallistic))
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testAllEnabled() {
        guard let mockResponseDataURL = Bundle(for: type(of: self)).url(forResource: "DevicePreferencesAllOnResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = DevicePreferencesRequest()
            let result = try request.parseResponse(URLResponse(), toRequest: URLRequest(url: URL(string: "foo")!), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssert(result.contains(.creatorPost))
            XCTAssert(result.contains(.followPost))
            XCTAssert(result.contains(.commentPost))
            XCTAssert(result.contains(.privateMessage))
            XCTAssert(result.contains(.newFollower))
            XCTAssert(result.contains(.tagPost))
            XCTAssert(result.contains(.mention))
            XCTAssert(result.contains(.likePost))
            XCTAssert(result.contains(.announcement))
            XCTAssert(result.contains(.nextDay))
            XCTAssert(result.contains(.lapsedUser))
            XCTAssert(result.contains(.emotiveBallistic))
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testChangeRequest() {
        let request = DevicePreferencesRequest(preferences: [.creatorPost: true, .newFollower: false])
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.HTTPMethod, "POST")
        
        guard let bodyData = urlRequest.httpBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: String.Encoding.utf8)!
        
        XCTAssertNotNil(bodyString.range(of: "notification_creator_post=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_new_follower=0"))
    }
    
    func testChangeRequestAllOff() {
        let request = DevicePreferencesRequest(preferences: [.creatorPost: false,
            .followPost: false,
            .commentPost: false,
            .privateMessage: false,
            .newFollower: false,
            .tagPost: false,
            .mention: false,
            .likePost: false,
            .announcement: false,
            .nextDay: false,
            .lapsedUser: false,
            .emotiveBallistic: false])
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.HTTPMethod, "POST")
        
        guard let bodyData = urlRequest.httpBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: String.Encoding.utf8)!
        
        XCTAssertNotNil(bodyString.range(of: "notification_creator_post=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_follow_post=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_comment_post=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_private_message=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_new_follower=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_tag_post=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_mention=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_like_post=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_announcement=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_next_day=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_lapsed_user=0"))
        XCTAssertNotNil(bodyString.range(of: "notification_emotive_ballistic=0"))
    }
    
    func testChangeRequestAllOn() {
        let request = DevicePreferencesRequest(preferences: [.creatorPost: true,
            .followPost: true,
            .commentPost: true,
            .privateMessage: true,
            .newFollower: true,
            .tagPost: true,
            .mention: true,
            .likePost: true,
            .announcement: true,
            .nextDay: true,
            .lapsedUser: true,
            .emotiveBallistic: true])
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.HTTPMethod, "POST")
        
        guard let bodyData = urlRequest.httpBody else {
            XCTFail("No HTTP Body!")
            return
        }
        let bodyString = String(data: bodyData, encoding: String.Encoding.utf8)!
        
        XCTAssertNotNil(bodyString.range(of: "notification_creator_post=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_follow_post=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_comment_post=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_private_message=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_new_follower=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_tag_post=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_mention=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_like_post=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_announcement=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_next_day=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_lapsed_user=1"))
        XCTAssertNotNil(bodyString.range(of: "notification_emotive_ballistic=1"))
    }
}
