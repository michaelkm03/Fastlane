//
//  SubscriptionSettingsTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class SubscriptionSettingsTests: XCTestCase {
    var settings: SubscriptionSettings!
    let testProductIdentifier = "com.getvictorious.product.subscription"

    override func setUp() {
        super.setUp()
        let dependencyManager = VDependencyManager(parentManager: nil,
            configuration: [
                kSubscriptionTemplateKey: [
                    kProductIdentifierTemplateKey: testProductIdentifier
                ]
            ],
            dictionaryOfClassesByTemplateName: nil)
        self.settings = SubscriptionSettings(dependencyManager: dependencyManager)
    }

    func testGettingProductIdentifier() {
        XCTAssertEqual(testProductIdentifier, settings.getProductIdentifier())
    }
}
