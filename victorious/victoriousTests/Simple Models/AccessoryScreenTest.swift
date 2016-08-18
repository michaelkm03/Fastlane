//
//  AccessoryScreenTest.swift
//  victorious
//
//  Created by Jarod Long on 8/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class AccessoryScreenTest: XCTestCase {
    func testInitWithDependencyManager() {
        let screen1 = AccessoryScreen(dependencyManager: VDependencyManager(dictionary: [
            "identifier": "cool_screen",
            "title": "Cool Screen",
            "position": "right"
        ]))
        
        XCTAssertEqual(screen1?.id, "cool_screen")
        XCTAssertEqual(screen1?.title, "Cool Screen")
        XCTAssertEqual(screen1?.position, .right)
        
        let screen2 = AccessoryScreen(dependencyManager: VDependencyManager(dictionary: [
            "identifier": "empty_screen"
        ]))
        
        XCTAssertEqual(screen2?.id, "empty_screen")
        XCTAssertNil(screen2?.title)
        XCTAssertEqual(screen2?.position, .left)
        
        let screen3 = AccessoryScreen(dependencyManager: VDependencyManager(dictionary: [:]))
        XCTAssertNil(screen3)
    }
}
