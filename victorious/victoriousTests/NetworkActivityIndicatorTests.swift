//
//  NetworkActivityIndicatorTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
@testable import victorious
import XCTest

class NetworkActivityIndicatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testUsage() {
        let indicator = NetworkActivityIndicator()
        XCTAssertFalse( indicator.visible )
        indicator.start()
        XCTAssert( indicator.visible )
        indicator.start()
        XCTAssert( indicator.visible )
        indicator.stop()
        XCTAssert( indicator.visible )
        indicator.stop()
        XCTAssertFalse( indicator.visible )
        indicator.start()
        XCTAssert( indicator.visible )
        indicator.start()
        XCTAssert( indicator.visible )
        indicator.stop()
        XCTAssert( indicator.visible )
        indicator.stop()
        XCTAssertFalse( indicator.visible )
    }
}
