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
        controller = IMAAdViewController(player: player, adTag: testAdTag, adsLoader: testAdsLoader)
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

    func testAdLoaded() {
        let loadedEvent = TestIMAAdEvent(test: true, type: .LOADED)
        XCTAssertEqual(0, delegateViewController.adDidLoadCallCount)
        XCTAssertEqual(0, testAdsManager.startCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: loadedEvent)
        XCTAssertEqual(1, delegateViewController.adDidLoadCallCount)
        XCTAssertEqual(1, testAdsManager.startCallCount)
    }

    func testAdStarted() {
        let startedEvent = TestIMAAdEvent(test: true, type: .STARTED)
        XCTAssertEqual(0, delegateViewController.adDidStartPlaybackCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: startedEvent)
        XCTAssertEqual(1, delegateViewController.adDidStartPlaybackCallCount)
    }

    func testLearnMoreTapped() {
        let clickedEvent = TestIMAAdEvent(test: true, type: .CLICKED)
        XCTAssertEqual(0, testAdsManager.discardAdBreakCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: clickedEvent)
        XCTAssertEqual(1, testAdsManager.discardAdBreakCallCount)

        XCTAssertEqual(0, delegateViewController.adDidFinishCallCount)
        controller.webOpenerDidCloseInAppBrowser(NSObject())
        XCTAssertEqual(1, delegateViewController.adDidFinishCallCount)
    }

    func testAdCopleted() {
        let completeEvent = TestIMAAdEvent(test: true, type: .COMPLETE)
        XCTAssertEqual(0, delegateViewController.adDidFinishCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: completeEvent)
        XCTAssertEqual(1, delegateViewController.adDidFinishCallCount)
    }

    func testAllAdsCompleted() {
        let allAdsCompleteEvent = TestIMAAdEvent(test: true, type: .ALL_ADS_COMPLETED)
        XCTAssertEqual(0, delegateViewController.adDidFinishCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: allAdsCompleteEvent)
        XCTAssertEqual(1, delegateViewController.adDidFinishCallCount)
    }

    func testAdSkipped() {
        let adSkippedEvent = TestIMAAdEvent(test: true, type: .SKIPPED)
        XCTAssertEqual(0, delegateViewController.adDidFinishCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adSkippedEvent)
        XCTAssertEqual(1, delegateViewController.adDidFinishCallCount)
    }

    func testAdTapped() {
        let adTappedEvent = TestIMAAdEvent(test: true, type: .TAPPED)
        XCTAssertEqual(0, delegateViewController.adHadImpressionCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adTappedEvent)
        XCTAssertEqual(1, delegateViewController.adHadImpressionCallCount)
    }

    func testAdReachedFirstQuartile() {
        let adReachedFirstQuartileEvent = TestIMAAdEvent(test: true, type: .FIRST_QUARTILE)
        XCTAssertEqual(0, delegateViewController.adDidHitFirstQuartileCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adReachedFirstQuartileEvent)
        XCTAssertEqual(1, delegateViewController.adDidHitFirstQuartileCallCount)
    }

    func testAdReachedMidpoint() {
        let adReachedMidpointEvent = TestIMAAdEvent(test: true, type: .MIDPOINT)
        XCTAssertEqual(0, delegateViewController.adDidHitMidpointCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adReachedMidpointEvent)
        XCTAssertEqual(1, delegateViewController.adDidHitMidpointCallCount)
    }

    func testAdReachedThirdQuartile() {
        let adReachedThirdQuartileEvent = TestIMAAdEvent(test: true, type: .THIRD_QUARTILE)
        XCTAssertEqual(0, delegateViewController.adDidHitThirdQuartileCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adReachedThirdQuartileEvent)
        XCTAssertEqual(1, delegateViewController.adDidHitThirdQuartileCallCount)
    }
}
