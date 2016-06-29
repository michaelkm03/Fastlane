//
//  ContentMediaSizeTests.swift
//  victorious
//
//  Created by Jarod Long on 6/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class ContentMediaSizeTests: XCTestCase {
    func testPreferredHeight() {
        XCTAssertEqual(ContentMediaSize(aspectRatio: 1.0 / 1.0, preferredWidth: 100.0).preferredHeight, 100.0)
        XCTAssertEqual(ContentMediaSize(aspectRatio: 2.0 / 3.0, preferredWidth: 300.0).preferredHeight, 200.0)
        XCTAssertEqual(ContentMediaSize(aspectRatio: 2.0 / 1.0, preferredWidth: 200.0).preferredHeight, 100.0)
    }
    
    func testPreferredSizeClampedToWidth() {
        XCTAssertEqual(
            ContentMediaSize(aspectRatio: 3.0 / 4.0, preferredWidth: 100.0).preferredSize(clampedToWidth: 200.0),
            CGSize(width: 100.0, height: 125.0)
        )
        
        XCTAssertEqual(
            ContentMediaSize(aspectRatio: 3.0 / 4.0, preferredWidth: 100.0).preferredSize(clampedToWidth: 50.0),
            CGSize(width: 50.0, height: 62.5)
        )
    }
    
    func testSupportedSizeClosestToAspectRatio() {
        XCTAssertEqual(
            ContentMediaSize(aspectRatio: 4.0 / 5.0, preferredWidth: 160.0),
            ContentMediaSize.supportedSize(closestToAspectRatio: 4.0 / 5.0)
        )
        
        XCTAssertEqual(
            ContentMediaSize(aspectRatio: 1.0 / 1.0, preferredWidth: 180.0),
            ContentMediaSize.supportedSize(closestToAspectRatio: 0.95)
        )
        
        XCTAssertEqual(
            ContentMediaSize(aspectRatio: 16.0 / 9.0, preferredWidth: 240.0),
            ContentMediaSize.supportedSize(closestToAspectRatio: 100000.0)
        )
        
        XCTAssertEqual(
            ContentMediaSize(aspectRatio: 9.0 / 16.0, preferredWidth: 135.0),
            ContentMediaSize.supportedSize(closestToAspectRatio: 0.0)
        )
    }
}
