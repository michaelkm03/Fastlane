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
        let path = url.pathWithoutLeadingSlash
        XCTAssertEqual(path, expectedURLString)
        XCTAssertFalse(url.isHTTPScheme)
    }
    
    func testEmptyPath() {
        let urlString = "https://www.example.com"
        let url = NSURL(string: urlString)!
        let path = url.pathWithoutLeadingSlash
        XCTAssertNil(path)
        XCTAssert(url.isHTTPScheme)
    }
    
    func testEmptyURL() {
        let urlString = ""
        let url = NSURL(string: urlString)!
        let path = url.pathWithoutLeadingSlash
        XCTAssertNil(path)
        XCTAssertFalse(url.isHTTPScheme)
    }
    
    func testNonHTTPScheme() {
        let urlString = "spotify://search:asdf"
        let url = NSURL(string: urlString)!
        XCTAssertFalse(url.isHTTPScheme)
    }
}
