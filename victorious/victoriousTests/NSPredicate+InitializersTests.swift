//
//  NSPredicate+InitializersTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class NSPredicate_InitializersTests: XCTestCase {

    func testPredicateFromAssetMediaType() {
        
        XCTAssertNil(NSPredicate.predicateWithAssetMediaType(.Unknown))
        XCTAssertNotNil(NSPredicate.predicateWithAssetMediaType(.Image))
        XCTAssertNotNil(NSPredicate.predicateWithAssetMediaType(.Video))
        XCTAssertNotNil(NSPredicate.predicateWithAssetMediaType(.Audio))
    }
}
