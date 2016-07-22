//
//  UserTests.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

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
        XCTAssertEqual(user.id, 36179)
        XCTAssertEqual(user.email, "tyt@creator.us")
        XCTAssertEqual(user.name, "The Young Turks")
        XCTAssertEqual(user.accessLevel, User.AccessLevel.owner)
        XCTAssertEqual(user.location, "Fargo, ND")
        XCTAssertEqual(user.tagline, "My coolest tagline")
        XCTAssertEqual(user.fanLoyalty?.points, Int(2764))
        XCTAssertEqual(user.numberOfFollowers, Int(15))
        XCTAssertEqual(user.likesGiven, 99)
        XCTAssertEqual(user.likesReceived, 40)
        
        guard let vipStatus = user.vipStatus, let vipEndDate = vipStatus.endDate else {
            XCTFail("Failed to parse `VIPStatus` of `User`.")
            return
        }
        
        XCTAssertEqual(vipStatus.isVIP, true)
        let dateFormatter = NSDateFormatter(vsdk_format: .Standard)
        XCTAssertEqual(dateFormatter.stringFromDate(vipEndDate), "2016-05-02 18:22:50")
        
        let previewImages = user.previewImages
        if previewImages.count == 2 {
            XCTAssertEqual(previewImages[0].url, NSURL(string: "https://d36dd6wez3mcdh.cloudfront.net/67ad37b710f11cea3c52feec037bcf10/80x80.jpg"))
            XCTAssertEqual(previewImages[0].size, CGSize(width: 80, height: 80))
            XCTAssertEqual(previewImages[1].url, NSURL(string: "https://d36dd6wez3mcdh.cloudfront.net/67ad37b710f11cea3c52feec037bcf10/100x100.jpg"))
            XCTAssertEqual(previewImages[1].size, CGSize(width: 100, height: 100))
        } else {
            XCTFail("Expected 2 image assets in the avatar property")
        }
    }
}
