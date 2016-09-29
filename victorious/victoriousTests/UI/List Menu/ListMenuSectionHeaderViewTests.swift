//
//  ListMenuSectionHeaderViewTests.swift
//  victorious
//
//  Created by Tian Lan on 9/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ListMenuSectionHeaderViewTests: XCTestCase {
    func testSubscribeButton() {
        let header = ListMenuSectionHeaderView()
        XCTAssertNil(header.subscribeButton)
        
        let dependencyManager = VDependencyManager(dictionary: [:])
        header.dependencyManager = dependencyManager
        
        XCTAssertNotNil(header.subscribeButton)
        XCTAssertEqual(header.subviews.count, 1)
    }
}
