//
//  NSURL+MimeTypeTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class NSURL_MimeTypeTests: XCTestCase {

    func testJPG() {
        let url = NSURL(fileURLWithPath: "/mypic.jpg")
        let mime = url.vsdk_mimeType
        XCTAssertEqual(mime, "image/jpeg")
    }
    
    func testPNG() {
        let url = NSURL(fileURLWithPath: "/mypic.png")
        let mime = url.vsdk_mimeType
        XCTAssertEqual(mime, "image/png")
    }
    
    func testUnknown() {
        let url = NSURL(fileURLWithPath: "/mypic.\(NSUUID().UUIDString)")
        let mime = url.vsdk_mimeType
        XCTAssertNil(mime)
    }
}
