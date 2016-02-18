//
//  TestIMAAdEvent.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious

class TestIMAAdEvent: IMAAdEvent {
    var testType: IMAAdEventType
    var testAd: TestIMAAd?

    override var ad: IMAAd? {
        return testAd
    }

    override var type: IMAAdEventType {
        return testType
    }

    init(test: Bool, type: IMAAdEventType, ad: TestIMAAd? = nil) {
        testType = type
        testAd = ad
    }
}
