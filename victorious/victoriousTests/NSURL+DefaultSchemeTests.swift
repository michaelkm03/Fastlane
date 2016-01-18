//
//  NSURL+DefaultSchemeTests.swift
//  victorious
//
//  Created by Josh Hinman on 1/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class NSURL_DefaultSchemeTests: XCTestCase {

    func testNonEmptyScheme() {
        let urlString = "ftp://example.com"
        let expectedUrl = NSURL(string: urlString)
        let actualUrl = NSURL.v_URLWithString(urlString, defaultScheme: "http")
        XCTAssertEqual(expectedUrl, actualUrl)
    }
    
    func testInvalidURL() {
        let url = NSURL.v_URLWithString("🍟", defaultScheme: "http")
        XCTAssertNil(url)
    }
    
    func testMissingScheme() {
        let urlString = "example.com"
        let expectedUrl = NSURL(string: "http://example.com")
        let actualUrl = NSURL.v_URLWithString(urlString, defaultScheme: "http")
        XCTAssertEqual(expectedUrl, actualUrl)
    }
}
