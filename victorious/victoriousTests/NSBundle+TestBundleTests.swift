//
//  NSBundle+TestBundleTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class NSBundlePlusTestBundleTests: XCTestCase {
    func testRunningInTestMode() {
        XCTAssertEqual(true, Bundle.v_isTestBundle)
    }
}
