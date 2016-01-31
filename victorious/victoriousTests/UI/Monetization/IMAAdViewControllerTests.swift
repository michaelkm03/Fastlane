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
    var testAdsLoader: TestIMAAdsLoader!
    var controller: IMAAdViewController!
    var delegateViewController: TestVAdViewControllerDelegateImplementor!

    override func setUp() {
        super.setUp()
        testAdsLoader = TestIMAAdsLoader()
        controller = IMAAdViewController(player: player, adTag: testAdTag, nibName: nil, nibBundle: nil, adsLoader: testAdsLoader)
        delegateViewController = TestVAdViewControllerDelegateImplementor()
        controller.adsManager = testAdsManager
        controller.delegate = delegateViewController
    }

    func testInit() {
        XCTAssert(controller.adsLoader.delegate === controller)
    }

    func testStartAdManager() {
        controller.startAdManager()
        XCTAssertEqual(1, testAdsLoader.requestAdsWithRequestCallCount)
    }

    func testAdsLoaded() {
        let loadedEvent = TestIMAAdEvent(test: true, type: .LOADED)
        XCTAssertEqual(0, delegateViewController.adDidLoadForAdViewControllerCallCount)
        XCTAssertEqual(0, testAdsManager.startCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: loadedEvent)
        XCTAssertEqual(1, delegateViewController.adDidLoadForAdViewControllerCallCount)
        XCTAssertEqual(1, testAdsManager.startCallCount)
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
