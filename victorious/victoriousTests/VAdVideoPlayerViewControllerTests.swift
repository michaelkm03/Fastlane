//
//  VAdVideoPlayerViewControllerTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VAdVideoPlayerViewControllerTests: BasePersistentStoreTestCase {
    func testInit() {
        let player = VVideoView()
        let adBreak = persistentStoreHelper.createAdBreak()
        guard let controller = VAdVideoPlayerViewController(monetizationPartner: VMonetizationPartner.IMA, adBreak: adBreak,
            player: player) else {
                XCTFail("Failed to instantiate VAdVideoPlayerViewController with a valid MonetizationPartner")
                return
        }
        XCTAssertEqual(VMonetizationPartner.IMA, controller.monetizationPartner)
        XCTAssertNil(VAdVideoPlayerViewController(monetizationPartner: VMonetizationPartner.None, adBreak: adBreak, player: player))
        XCTAssertNil(VAdVideoPlayerViewController(monetizationPartner: VMonetizationPartner.Count, adBreak: adBreak, player: player))
    }
}
