//
//  NSPredicate+MediaTypeTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class NSPredicate_MediaTypeTests: XCTestCase {

    func testPredicateFromAssetMediaType() {
        
        XCTAssertNil(NSPredicate.predicateWithAssetMediaType(.unknown))
        XCTAssertNotNil(NSPredicate.predicateWithAssetMediaType(.image))
        XCTAssertNotNil(NSPredicate.predicateWithAssetMediaType(.video))
        XCTAssertNotNil(NSPredicate.predicateWithAssetMediaType(.audio))
    }
}
