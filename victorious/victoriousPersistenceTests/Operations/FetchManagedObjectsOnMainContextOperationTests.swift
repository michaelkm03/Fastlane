//
//  FetchManagedObjectsOnMainContextOperationTests.swift
//  victorious
//
//  Created by Michael Sena on 1/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class FetchManagedObjectsOnMainContextOperationTests: XCTestCase {

    private let testRemoteID = 666
    
    var testStore: TestPersistentStore!
    var persistentStoreHelper: PersistentStoreTestHelper!
    
    override func setUp() {
        super.setUp()
        testStore = TestPersistentStore()
        persistentStoreHelper = PersistentStoreTestHelper(persistentStore: testStore)
    }
    
    func testFindsExpectedManagedObjects() {
        persistentStoreHelper.createUser(remoteId: testRemoteID)
        let fetchManagedObjectsOperation = FetchManagedObjectsOnMainContextOperation(withEntityName: VUser.v_entityName(), queryDictionary: ["remoteId": testRemoteID])
        
        queueExpectedOperation(operation: fetchManagedObjectsOperation)
        waitForExpectationsWithTimeout(1) { error in
            guard let results = fetchManagedObjectsOperation.result else {
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

    func queueExpectedOperation(operation operation: Operation) -> XCTestExpectation {
        let expectation = expectationWithDescription("operation completed")
        operation.queue() { error in
            expectation.fulfill()
        }
        return expectation
    }

}
