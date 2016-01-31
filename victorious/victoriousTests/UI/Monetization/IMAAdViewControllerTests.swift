//
//  IMAAdViewControllerTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class IMAAdViewControllerTests: XCTestCase {
    let player = VVideoView()
    let testAdTag = "http://example.com/adTag"
    let adsManager = TestIMAAdsManager(test: true)
    var controller: IMAAdViewController!

    override func setUp() {
        super.setUp()
        controller = IMAAdViewController(player: player, adTag: testAdTag)
        controller.adsManager = adsManager
    }

    func testInit() {
        XCTAssert(controller.adsLoader.delegate === controller)
    }

    func testAdsLoaded() {
        let delegateViewController = TestVAdViewControllerDelegateImplementor()
        controller.delegate = delegateViewController
        let loadedEvent = TestIMAAdEvent(test: true, type: .LOADED)
        XCTAssertEqual(0, delegateViewController.adDidLoadForAdViewControllerCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: loadedEvent)
        XCTAssertEqual(1, delegateViewController.adDidLoadForAdViewControllerCallCount)
    }
}
