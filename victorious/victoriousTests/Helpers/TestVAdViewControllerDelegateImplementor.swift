//
//  TestVAdViewControllerDelegateImplementor.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious

class TestVAdViewControllerDelegateImplementor: NSObject, VAdViewControllerDelegate {
    var adDidLoadForAdViewControllerCallCount = 0
    var adDidFinishForAdViewControllerCallCount = 0
    var adDidStartPlaybackInAdViewControllerCallCount = 0
    var adHadImpressionInAdViewControllerCallCount = 0
    var adDidHitFirstQuartileInAdViewController = 0
    var adDidHitMidpointInAdViewControllerCallCount = 0
    var adDidHitThirdQuartileInAdViewControllerCallCount = 0

    func adDidLoadForAdViewController(adViewController: VAdViewController!) {
        adDidLoadForAdViewControllerCallCount += 1
    }

    func adDidFinishForAdViewController(adViewController: VAdViewController!) {
        adDidFinishForAdViewControllerCallCount += 1
    }

    func adDidStartPlaybackInAdViewController(adViewController: VAdViewController!) {
        adDidStartPlaybackInAdViewControllerCallCount += 1
    }

    func adHadImpressionInAdViewController(adViewController: VAdViewController!) {
        adHadImpressionInAdViewControllerCallCount += 1
    }

    func adDidHitFirstQuartileInAdViewController(adViewController: VAdViewController!) {
        adDidHitFirstQuartileInAdViewController += 1
    }

    func adDidHitMidpointInAdViewController(adViewController: VAdViewController!) {
        adDidHitMidpointInAdViewControllerCallCount += 1
    }

    func adDidHitThirdQuartileInAdViewController(adViewController: VAdViewController!) {
        adDidHitThirdQuartileInAdViewControllerCallCount += 1
    }
}
