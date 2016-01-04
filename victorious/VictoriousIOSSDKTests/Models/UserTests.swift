//
//  UserTests.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class UserTests: XCTestCase {

    func testJSONParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("User", withExtension: "json"),
              let mockData = NSData(contentsOfURL: mockUserDataURL) else {
            XCTFail("Error reading mock json data")
            return
        }
        guard let user = User(json: JSON(data: mockData)) else {
            XCTFail("User initializer failed")
            return
        }
        XCTAssertEqual(user.userID, 36179)
        XCTAssertEqual(user.email, "tyt@creator.us")
        XCTAssertEqual(user.name, "The Young Turks")
        XCTAssertEqual(user.status, ProfileStatus.Complete)
        XCTAssertEqual(user.location, "Fargo, ND")
        XCTAssertEqual(user.tagline, "My coolest tagline")
        XCTAssertEqual(user.fanLoyalty?.points, Int64(2764))
        XCTAssertEqual(user.numberOfFollowers, Int64(15))
        
        if let previewImageAssets = user.previewImageAssets where previewImageAssets.count == 2 {
            XCTAssertEqual(previewImageAssets[0].url, NSURL(string: "https://d36dd6wez3mcdh.cloudfront.net/67ad37b710f11cea3c52feec037bcf10/80x80.jpg"))
            XCTAssertEqual(previewImageAssets[0].size, CGSize(width: 80, height: 80))
            XCTAssertEqual(previewImageAssets[1].url, NSURL(string: "https://d36dd6wez3mcdh.cloudfront.net/67ad37b710f11cea3c52feec037bcf10/100x100.jpg"))
            XCTAssertEqual(previewImageAssets[1].size, CGSize(width: 100, height: 100))
        } else {
            XCTFail("Expected 2 image assets in the avatar property")
        }
    }
}
