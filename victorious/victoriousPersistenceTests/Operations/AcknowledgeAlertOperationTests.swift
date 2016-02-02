//
//  AcknowledgeAlertOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class AcknowledgeAlertOperationTests: BaseRequestOperationTestCase {

    var operation: AcknowledgeAlertOperation!
    let alertID = 99
    
    override func setUp() {
        super.setUp()
        operation = AcknowledgeAlertOperation(alertID: 5)
        operation.requestExecutor = testRequestExecutor
    }
    
    func testExecutesRequest() {
        operation.main()
        XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
    }
}
