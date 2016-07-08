//
//  AppVersionTests.swift
//  victorious
//
//  Created by Michael Sena on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class AppVersionTests: XCTestCase {

    func testAppVersionComparison() {
        
        let appVersion10 = AppVersion(versionNumber: "1.0")
        let appVersion10Duplicate = AppVersion(versionNumber: "1.0")
        let appVersion11 = AppVersion(versionNumber: "1.1")
        
        // The same version should equal itself
        XCTAssertEqual(appVersion10, appVersion10Duplicate)
        
        // 1.0 vs 1.1 comparisons
        XCTAssertTrue(appVersion10 < appVersion11)
        XCTAssertTrue(appVersion10 != appVersion11)
        XCTAssertFalse(appVersion10 == appVersion11)
        XCTAssertFalse(appVersion10 > appVersion11)
        
        // Trailing .0s should have no effect on equality
        let appVersion100 = AppVersion(versionNumber: "1.0.0")
        XCTAssertEqual(appVersion10, appVersion100)
        
        // Support multiple component app version numbers
        let appVersion101 = AppVersion(versionNumber: "1.0.1")
        let appVersion102 = AppVersion(versionNumber: "1.0.2")
        XCTAssertLessThan(appVersion101, appVersion102)
        XCTAssertGreaterThan(appVersion102, appVersion101)
        
        XCTAssertEqual(appVersion101.string, "1.0.1")
    }

}
