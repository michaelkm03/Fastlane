//
//  Bool+InitializersTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class BoolInitializerTests: XCTestCase {
    
    func testString() {
        XCTAssertTrue(Bool("true") ?? false)
        XCTAssertTrue(Bool("YES") ?? false)
        XCTAssertFalse(Bool("false") ?? true)
        XCTAssertFalse(Bool("NO") ?? true)
        XCTAssertNil(Bool("blah"))
    }
    
    func testInt() {
        XCTAssertTrue(Bool(1) ?? false)
        XCTAssertFalse(Bool(0) ?? true)
        XCTAssertNil(Bool(7))
    }
}
