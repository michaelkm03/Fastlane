//
//  String+InitialsTests.swift
//  victorious
//
//  Created by Jarod Long on 7/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious
import XCTest

class String_InitialsTests: XCTestCase {
    func testInitials() {
        XCTAssertEqual("Cool Guy".initials(), "CG")
        XCTAssertEqual("Cool Guy".initials(maxCount: 1), "C")
        XCTAssertEqual("Guy".initials(), "G")
        XCTAssertEqual("".initials(), "")
        XCTAssertEqual("some string containing lots of words".initials(), "SW")
        XCTAssertEqual("some string containing lots of words".initials(maxCount: 3), "SSW")
        XCTAssertEqual("some string containing lots of words".initials(maxCount: 4), "SSCW")
        XCTAssertEqual("some string containing lots of words".initials(maxCount: 999), "SSCLOW")
        XCTAssertEqual("🍉🍏 🍯🐝".initials(), "🍉🍯")
        XCTAssertEqual("王艳 张磊".initials(), "王张")
    }
}
