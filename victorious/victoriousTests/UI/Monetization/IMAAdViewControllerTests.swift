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
    let testAdsManager = TestIMAAdsManager(test: true)
    var controller: IMAAdViewController!
    var delegateViewController: TestVAdViewControllerDelegateImplementor!

    override func setUp() {
        super.setUp()
        controller = IMAAdViewController(player: player, adTag: testAdTag)
        delegateViewController = TestVAdViewControllerDelegateImplementor()
        controller.adsManager = testAdsManager
        controller.delegate = delegateViewController
    }

    func testInit() {
        XCTAssert(controller.adsLoader.delegate === controller)
    }

    func testAdsLoaded() {
        let loadedEvent = TestIMAAdEvent(test: true, type: .LOADED)
        XCTAssertEqual(0, delegateViewController.adDidLoadForAdViewControllerCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: loadedEvent)
        XCTAssertEqual(1, delegateViewController.adDidLoadForAdViewControllerCallCount)
    }

    func testAdStarted() {
        let startedEvent = TestIMAAdEvent(test: true, type: .STARTED)
        XCTAssertEqual(0, delegateViewController.adDidStartPlaybackInAdViewControllerCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: startedEvent)
        XCTAssertEqual(1, delegateViewController.adDidStartPlaybackInAdViewControllerCallCount)
    }

    func testLearnMoreTapped() {
        let clickedEvent = TestIMAAdEvent(test: true, type: .CLICKED)
        XCTAssertEqual(0, testAdsManager.discardAdBreakCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: clickedEvent)
        XCTAssertEqual(1, testAdsManager.discardAdBreakCallCount)

        XCTAssertEqual(0, delegateViewController.adDidFinishForAdViewControllerCallCount)
        controller.viewDidAppear(false)
        XCTAssertEqual(1, delegateViewController.adDidFinishForAdViewControllerCallCount)
    }
}
