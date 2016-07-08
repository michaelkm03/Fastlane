//
//  AlertAcknowledgeOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class AlertAcknowledgeOperationTests: BaseFetcherOperationTestCase {

    var operation: AlertAcknowledgeOperation!
    let alertID = 99
    
    override func setUp() {
        super.setUp()
        operation = AlertAcknowledgeOperation(alertID: "5")
        operation.requestExecutor = testRequestExecutor
    }
    
    func testExecutesRequest() {
        operation.main()
        XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
    }
}
