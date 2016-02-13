//
//  TestAdLifecycleDelegate.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious

class TestAdLifecycleDelegate: NSObject, AdLifecycleDelegate {
    var adDidLoadCallCount = 0
    var adDidFinishCallCount = 0
    var adDidStartCallCount = 0
    var adHadErrorCallCount = 0
    var adHadImpressionCallCount = 0
    var adDidHitFirstQuartileCallCount = 0
    var adDidHitMidpointCallCount = 0
    var adDidHitThirdQuartileCallCount = 0

    func adHadError(error: NSError!) {
        adHadErrorCallCount += 1
    }

    func adDidLoad() {
        adDidLoadCallCount += 1
    }

    func adDidFinish() {
        adDidFinishCallCount += 1
    }

    func adDidStart() {
        adDidStartCallCount += 1
    }

    func adHadImpression() {
        adHadImpressionCallCount += 1
    }

    func adDidHitFirstQuartile() {
        adDidHitFirstQuartileCallCount += 1
    }

    func adDidHitMidpoint() {
        adDidHitMidpointCallCount += 1
    }

    func adDidHitThirdQuartile() {
        adDidHitThirdQuartileCallCount += 1
    }
}
