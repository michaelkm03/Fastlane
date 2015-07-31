//
//  NSString+UnicodeTests.swift
//  victorious
//
//  Created by Patrick Lynch on 7/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import XCTest

class NSString_UnicodeTests: XCTestCase {

    func testExample() {
        XCTAssertEqual( NSString(string: "😄").lengthWithUnicode, 1 )
        XCTAssertEqual( NSString(string: "😃").lengthWithUnicode, 1 )
        XCTAssertEqual( NSString(string: "😍").lengthWithUnicode, 1 )
        XCTAssertEqual( NSString(string: "😜").lengthWithUnicode, 1 )
        XCTAssertEqual( NSString(string: "💏").lengthWithUnicode, 1 )
        XCTAssertEqual( NSString(string: "👏").lengthWithUnicode, 1 )
        XCTAssertEqual( NSString(string: "💆").lengthWithUnicode, 1 )
        XCTAssertEqual( NSString(string: "👀").lengthWithUnicode, 1 )
        XCTAssertEqual( NSString(string: "📱📪").lengthWithUnicode, 2 )
        XCTAssertEqual( NSString(string: "👏😃").lengthWithUnicode, 2 )
        XCTAssertEqual( NSString(string: "💆😜").lengthWithUnicode, 2 )
        XCTAssertEqual( NSString(string: "👀👏").lengthWithUnicode, 2 )
        XCTAssertEqual( NSString(string: "📱📛").lengthWithUnicode, 2 )
        XCTAssertEqual( NSString(string: "📱📪🍤").lengthWithUnicode, 3 )
        XCTAssertEqual( NSString(string: "👏😃🍦").lengthWithUnicode, 3 )
        XCTAssertEqual( NSString(string: "💆😜🌽").lengthWithUnicode, 3 )
        XCTAssertEqual( NSString(string: "👀👏🗿").lengthWithUnicode, 3 )
        XCTAssertEqual( NSString(string: "📱📛🇩🇪").lengthWithUnicode, 3 )
    }

}
