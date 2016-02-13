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
        let adTag = "http://example.com/ads"
        let adViewController = IMAAdViewController(player: player, adTag: adTag)
        controller = VAdVideoPlayerViewController(adViewController: adViewController)
        controller.adViewController = testAdViewController
    }

    func testStart() {
        controller.start()
        XCTAssert(controller === testAdViewController.delegate)
        XCTAssertEqual(1, testAdViewController.startAdManagerCallCount)
    }
}
