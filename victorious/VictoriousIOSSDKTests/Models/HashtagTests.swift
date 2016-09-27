//
//  HashtagTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class HashtagTests: XCTestCase {
    
    func testJSONParsing() {
        guard
            let mockDataURL = NSBundle(forClass: self.dynamicType).URLForResource("Hashtag", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        guard let hashtag = Hashtag(json: JSON(data: mockData)) else {
            XCTFail("Hashtag initializer failed")
            return
        }
        XCTAssertEqual(hashtag.tag, "surfing")
    }
}
