//
//  AdVideoPlayerViewControllerTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class AdVideoPlayerViewControllerTests: XCTestCase {
    
    let testAdViewController = TestVAdViewController()
    var controller: AdVideoPlayerViewController!

    override func setUp() {
        super.setUp()
        let player = VVideoView()
        let adTag = "http://example.com/ads"
        let adViewController = IMAAdViewController(player: player, adTag: adTag)
        controller = AdVideoPlayerViewController(adViewController: adViewController)
        controller.adViewController = testAdViewController
    }

    func testStart() {
        controller.start()
        XCTAssert(controller === testAdViewController.delegate)
        XCTAssertEqual(1, testAdViewController.startAdManagerCallCount)
    }
}
