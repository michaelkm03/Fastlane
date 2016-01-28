//
//  TestVAdViewController.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import victorious

class TestVAdViewController: VAdViewController {
    var startAdManagerCallCount = 0

    override func startAdManager() {
        startAdManagerCallCount += 1
    }
}
