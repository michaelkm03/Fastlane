//
//  TestVAdViewController.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import victorious

class TestVAdViewController: NSObject, VAdViewControllerType {
    var startAdManagerCallCount = 0
    weak var delegate: AdLifecycleDelegate?
    var adView: UIView

    init(adView: UIView = UIView()) {
        self.adView = adView
    }

    func startAdManager() {
        startAdManagerCallCount += 1
    }
}
