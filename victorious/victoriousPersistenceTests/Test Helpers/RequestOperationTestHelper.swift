//
//  OperationHelper.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.

import XCTest
@testable import victorious

/// Helper class for testing a RequestOperation or it's subclass.
class RequestOperationTestHelper {
    func createUser(remoteId remoteId: Int64, persistentStore: PersistentStoreType) -> VUser {
        return persistentStore.mainContext.v_createObjectAndSave { user in
            user.remoteId = NSNumber(longLong: remoteId)
            user.status = "stored"
            } as VUser
    }

    func tearDownPersistentStore(store store: PersistentStoreType) {
        do {
            try store.deletePersistentStore()
        } catch PersistentStoreError.DeleteFailed(let storeURL, let error) {
            XCTFail("Failed to clear the test persistent store at \(storeURL) because of \(error)." +
                "Failing this test since it can cause test pollution.")
        } catch {
            XCTFail("Something went wrong while clearing persitent store")
        }
    }
}
