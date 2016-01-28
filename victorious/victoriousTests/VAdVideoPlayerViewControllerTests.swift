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
    var testStore: TestPersistentStore!
    let testAdViewController = TestVAdViewController()
    var controller: VAdVideoPlayerViewController!

    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        let player = VVideoView()
        let adBreak = createAdBreak()
        controller = VAdVideoPlayerViewController(adBreak: adBreak, player: player)
        controller.adViewController = testAdViewController
    }

    func testStart() {
        controller.start()
        XCTAssert(controller === testAdViewController.delegate)
        XCTAssertEqual(1, testAdViewController.startAdManagerCallCount)
    }

    private func createAdBreak() -> VAdBreak {
        return testStore.mainContext.v_createObjectAndSave() { adBreak in
        } as VAdBreak
    }
}
