//
//  NSURL+CustomSchemeTests.swift
//  victorious
//
//  Created by Tian Lan on 7/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class NSURL_CustomSchemeTests: XCTestCase {
    func testPathWithoutLeadingSlash() {
        let expectedURLString = "https://www.example.com"
        let url = NSURL(string: "vthisapp://webURL/\(expectedURLString)")!
        let path = url.pathWithoutLeadingSlash()
        XCTAssertEqual(path, expectedURLString)
    }
}
