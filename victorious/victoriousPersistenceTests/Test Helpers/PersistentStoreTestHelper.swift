//
//  PersistentStoreTestHelper.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.

import XCTest
@testable import victorious

/// Helper for testing a RequestOperation or it's subclass.
struct PersistentStoreTestHelper {

    let persistentStore: TestPersistentStore

    func createUser(remoteId remoteId: Int, token: String = "token") -> VUser {
        return persistentStore.mainContext.v_createObjectAndSave { user in
            user.remoteId = remoteId
            user.status = "stored"
            user.token = token
        } as VUser
    }
    
    func createConversation() -> VConversation {
        let conversation: VConversation = persistentStore.mainContext.v_createObject()
        conversation.remoteId = 0
        conversation.lastMessageText = ""
        conversation.isRead = false
        conversation.postedAt = NSDate()
        conversation.messages = NSOrderedSet()
        return conversation
    }

    func tearDownPersistentStore() {
        do {
            try persistentStore.deletePersistentStore()
        } catch PersistentStoreError.DeleteFailed(let storeURL, let error) {
            XCTFail("Failed to clear the test persistent store at \(storeURL) because of \(error)." +
                "Failing this test since it can cause test pollution.")
        } catch {
            XCTFail("Something went wrong while clearing persitent store")
        }
    }
}
