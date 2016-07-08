//
//  HashtagShelfTests.swift
//  victorious
//
//  Created by Tian Lan on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class HashtagShelfTests: XCTestCase {
    
    func testInvalid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("SimpleStream", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        XCTAssertNil(HashtagShelf(json: JSON(data: mockData)))
    }
}
