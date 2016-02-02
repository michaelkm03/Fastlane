//
//  TestIMAAdsLoader.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious

class TestIMAAdsLoader: IMAAdsLoader {
    var requestAdsWithRequestCallCount = 0

    override func requestAdsWithRequest(request: IMAAdsRequest!) {
        requestAdsWithRequestCallCount += 1
    }
}
