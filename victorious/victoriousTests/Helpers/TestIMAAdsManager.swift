//
//  TestIMAAdsManager.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious

class TestIMAAdsManager: IMAAdsManager {
    var discardAdBreakCallCount = 0

    init(test: Bool) {
    }

    override func discardAdBreak() {
        discardAdBreakCallCount += 1
    }
}
