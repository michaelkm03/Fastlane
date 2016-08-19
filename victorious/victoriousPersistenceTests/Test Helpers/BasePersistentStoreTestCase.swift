//
//  BasePersistentStoreTestCase.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

/// Provides plumbing for testing iteractions with a persistent store.
class BasePersistentStoreTestCase: XCTestCase {
    
    let expectationThreshold: Double = 1
    var persistentStoreHelper: PersistentStoreTestHelper!
    var testStore: PersistentStoreType!

    override func setUp() {
        super.setUp()
        testStore = PersistentStoreSelector.defaultPersistentStore
        (testStore as? TestPersistentStore)?.deletePersistentStore()
        persistentStoreHelper = PersistentStoreTestHelper(persistentStore: testStore)
        
        Queue.background.operationQueue.cancelAllOperations()
        Queue.background.operationQueue.suspended = false
        
        NSOperationQueue.mainQueue().cancelAllOperations()
        NSOperationQueue.mainQueue().suspended = false
    }
    
    override func tearDown() {
        super.tearDown()
        
        Queue.background.operationQueue.cancelAllOperations()
        Queue.background.operationQueue.suspended = true
        
        NSOperationQueue.mainQueue().cancelAllOperations()
        NSOperationQueue.mainQueue().suspended = true
    }
}
