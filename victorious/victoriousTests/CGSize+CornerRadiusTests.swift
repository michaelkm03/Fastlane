//
//  CGSize+CornerRadiusTests.swift
//  victorious
//
//  Created by Jarod Long on 3/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class CGSize_CornerRadiusTests: XCTestCase {
    
    func testRoundCornerRadius() {
        XCTAssertEqual(CGSize(width: 15.0, height: 20.0).v_roundCornerRadius, 7.5)
        XCTAssertEqual(CGSize(width: 25.0, height: 20.0).v_roundCornerRadius, 10.0)
    }
    
}
