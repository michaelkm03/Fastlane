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

    func adDidLoadForAdViewController(adViewController: VAdViewController!) {
        adDidLoadForAdViewControllerCallCount += 1
    }

    func adDidFinishForAdViewController(adViewController: VAdViewController!) {
        adDidFinishForAdViewControllerCallCount += 1
    }

    func adDidStartPlaybackInAdViewController(adViewController: VAdViewController!) {
        adDidStartPlaybackInAdViewControllerCallCount += 1
    }
}
