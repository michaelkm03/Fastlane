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
        let url = URL(fileURLWithPath: "/mypic.jpg")
        let mime = url.vsdk_mimeType
        XCTAssertEqual(mime, "image/jpeg")
    }
    
    func testPNG() {
        let url = URL(fileURLWithPath: "/mypic.png")
        let mime = url.vsdk_mimeType
        XCTAssertEqual(mime, "image/png")
    }
    
    func testUnknown() {
        let url = URL(fileURLWithPath: "/mypic.\(UUID().uuidString)")
        let mime = url.vsdk_mimeType
        XCTAssertNil(mime)
    }
}
