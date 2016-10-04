//
//  CommunityItemsFetchOperationTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class CommunityItemsFetchOperationTests: XCTestCase {
    func testExecuteWithValidData() {
        let validConfig = [
            "title": "COMMUNITY",
            "items": [
                [
                    "show.branding.icon": true,
                    "streamURL": "https://vapi-dev.getvictorious.com/v1/streams/recent/from/%%FROM_TIME%%/to/%%TO_TIME%%",
                    "name": "home.stream",
                    "title": "Home",
                    "tracking": [
                        "view": ["https://vapi-dev.getvictorious.com/v1/tracking/component_view/?component_name=home%2Estream"
                        ]
                    ]
                ],
                [
                    "streamURL": "https://vapi-dev.getvictorious.com/v1/streams/favorite/from/%%FROM_TIME%%/to/%%TO_TIME%%",
                    "name": "favorite.stream",
                    "title": "Following",
                    "tracking": [
                        "view": ["https://vapi-dev.getvictorious.com/v1/tracking/component_view/?component_name=favorite%2Estream"
                        ]
                    ]
                ]
            ]
        ]
        let dependencyManager = VDependencyManager(dictionary: validConfig)
        let operation = CommunityItemsFetchOperation(dependencyManager: dependencyManager)
        switch operation.execute() {
            case .success: XCTAssert(true)
            case .failure, .cancelled: XCTFail()
        }
    }

    func testExecuteWithInvalidData() {
        let invalidConfig = ["":""]
        let dependencyManager = VDependencyManager(dictionary: invalidConfig)
        let operation = CommunityItemsFetchOperation(dependencyManager: dependencyManager)
        switch operation.execute() {
            case .failure: XCTAssert(true)
            case .success, .cancelled: XCTFail()
        }
    }
}
