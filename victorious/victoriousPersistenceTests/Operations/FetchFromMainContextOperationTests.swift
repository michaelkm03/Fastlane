//
//  FetchFromMainContextOperationTests.swift
//  victorious
//
//  Created by Michael Sena on 1/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class FetchFromMainContextOperationTests: BasePersistentStoreTestCase {

    private let testRemoteID = 666
    
    override func setUp() {
        super.setUp()
    }
    
    func testFindsExpectedManagedObjects() {
        persistentStoreHelper.createUser(remoteId: testRemoteID)
        
        let fetchOperation = FetchFromMainContextOperation(
            entityName: VUser.v_entityName(),
            predicate: NSPredicate(format: "remoteId == %i", testRemoteID)
        )
        
        queueExpectedOperation(operation: fetchOperation)
        waitForExpectationsWithTimeout(1) { error in
            guard let results = fetchOperation.results else {
                XCTFail("We should have results.")
                return
            }
            XCTAssert(!results.isEmpty)
            if let firstUser = results.first as? VUser {
                XCTAssertEqual(firstUser.remoteId, self.testRemoteID)
            } else {
                XCTFail("There should be at least one user.")
            }
        }
    }

    func queueExpectedOperation(operation operation: FetcherOperation) -> XCTestExpectation {
        let expectation = expectationWithDescription("operation completed")
        operation.queue() { results, error, cancelled in
            expectation.fulfill()
        }
        return expectation
    }

}
