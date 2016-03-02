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
    let testAdTag = "http://example.com/adTag"
    let testAdsManager = TestIMAAdsManager(test: true)
    let player = TestVideoPlayer()
    let testAdsLoader = TestIMAAdsLoader()
    let testAdDelegate = TestAdLifecycleDelegate()
    
    var controller:IMAAdViewController!

    override func setUp() {
        super.setUp()

        controller = IMAAdViewController(player: player, adTag: testAdTag, adsLoader: testAdsLoader)
        controller.adsManager = testAdsManager
        controller.delegate = testAdDelegate
    }

    func testInit() {
        XCTAssert(controller.adsLoader.delegate === controller)
    }

    func testStartAdManager() {
        controller.startAdManager()
        XCTAssertEqual(1, testAdsLoader.requestAdsWithRequestCallCount)
    }

    func testAdLoaded() {
        let loadedEvent = TestIMAAdEvent(test: true, type: .LOADED, ad: TestIMAAd(test: true))
        XCTAssertEqual(0, testAdDelegate.adDidLoadCallCount)
        XCTAssertEqual(0, testAdsManager.startCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: loadedEvent)
        XCTAssertEqual(1, testAdDelegate.adDidLoadCallCount)
        XCTAssertEqual(1, testAdsManager.startCallCount)
    }

    func testAdStarted() {
        let startedEvent = TestIMAAdEvent(test: true, type: .STARTED)
        XCTAssertEqual(0, testAdDelegate.adDidStartCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: startedEvent)
        XCTAssertEqual(1, testAdDelegate.adDidStartCallCount)
    }

    func testLearnMoreTapped() {
        let clickedEvent = TestIMAAdEvent(test: true, type: .CLICKED)
        XCTAssertEqual(0, testAdsManager.discardAdBreakCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: clickedEvent)
        XCTAssertEqual(1, testAdsManager.discardAdBreakCallCount)

        XCTAssertEqual(0, testAdDelegate.adDidFinishCallCount)
        controller.webOpenerDidCloseInAppBrowser(NSObject())
        XCTAssertEqual(1, testAdDelegate.adDidFinishCallCount)
    }

    func testAdCopleted() {
        let completeEvent = TestIMAAdEvent(test: true, type: .COMPLETE)
        XCTAssertEqual(0, testAdDelegate.adDidFinishCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: completeEvent)
        XCTAssertEqual(1, testAdDelegate.adDidFinishCallCount)
    }

    func testAllAdsCompleted() {
        let allAdsCompletedEvent = TestIMAAdEvent(test: true, type: .ALL_ADS_COMPLETED)
        XCTAssertEqual(0, testAdDelegate.adDidFinishCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: allAdsCompletedEvent)
        XCTAssertEqual(1, testAdDelegate.adDidFinishCallCount)
    }

    func testAdCompletedFollowedByAllAdsCompleted() {
        let completeEvent = TestIMAAdEvent(test: true, type: .COMPLETE)
        let allAdsCompletedEvent = TestIMAAdEvent(test: true, type: .ALL_ADS_COMPLETED)
        XCTAssertEqual(0, testAdDelegate.adDidFinishCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: completeEvent)
        XCTAssertEqual(1, testAdDelegate.adDidFinishCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: allAdsCompletedEvent)
        XCTAssertEqual(1, testAdDelegate.adDidFinishCallCount)
    }

    func testAdSkipped() {
        let adSkippedEvent = TestIMAAdEvent(test: true, type: .SKIPPED)
        XCTAssertEqual(0, testAdDelegate.adDidFinishCallCount)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adSkippedEvent)
        XCTAssertEqual(1, testAdDelegate.adDidFinishCallCount)
    }

    func testAdTapped() {
        let adTappedEvent = TestIMAAdEvent(test: true, type: .TAPPED)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adTappedEvent)
    }

    func testAdReachedFirstQuartile() {
        let adReachedFirstQuartileEvent = TestIMAAdEvent(test: true, type: .FIRST_QUARTILE)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adReachedFirstQuartileEvent)
    }

    func testAdReachedMidpoint() {
        let adReachedMidpointEvent = TestIMAAdEvent(test: true, type: .MIDPOINT)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adReachedMidpointEvent)
    }

    func testAdReachedThirdQuartile() {
        let adReachedThirdQuartileEvent = TestIMAAdEvent(test: true, type: .THIRD_QUARTILE)
        controller.adsManager(controller.adsManager, didReceiveAdEvent: adReachedThirdQuartileEvent)
    }

    func testAdsManagerDidRequestContentPause() {
        XCTAssertEqual(0, player.pauseCallCount)
        controller.adsManagerDidRequestContentPause(controller.adsManager)
        XCTAssertEqual(1, player.pauseCallCount)
    }

    func testAdsManagerDidRequestContentResume() {
        XCTAssertEqual(0, player.playCallCount)
        controller.adsManagerDidRequestContentResume(controller.adsManager)
        XCTAssertEqual(1, player.playCallCount)
    }
}
