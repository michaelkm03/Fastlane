//
//  VAdVideoPlayerViewControllerTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VAdVideoPlayerViewControllerTests: XCTestCase {
    func testInit() {
        let player = VVideoView()
        guard let controller = VAdVideoPlayerViewController(monetizationPartner: .IMA, details: [], player: player) else {
            XCTFail("Failed to instantiate VAdVideoPlayerViewController with a valid MonetizationPartner")
            return
        }
        XCTAssertEqual(VMonetizationPartner.IMA, controller.monetizationPartner)
        XCTAssertNil(VAdVideoPlayerViewController(monetizationPartner: .None, details: [], player: player))
        XCTAssertNil(VAdVideoPlayerViewController(monetizationPartner: .Count, details: [], player: player))
    }
}
