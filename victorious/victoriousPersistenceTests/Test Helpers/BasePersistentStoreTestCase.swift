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
    
    let testStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore

    override func setUp() {
        super.setUp()
        (testStore as? TestPersistentStore)?.deletePersistentStore()
        persistentStoreHelper = PersistentStoreTestHelper(persistentStore: testStore)
        
        NSOperationQueue.v_globalBackgroundQueue.cancelAllOperations()
        NSOperationQueue.v_globalBackgroundQueue.suspended = false
        
        NSOperationQueue.mainQueue().cancelAllOperations()
        NSOperationQueue.mainQueue().suspended = false
    }
    
    override func tearDown() {
        super.tearDown()
        
        NSOperationQueue.v_globalBackgroundQueue.cancelAllOperations()
        NSOperationQueue.v_globalBackgroundQueue.suspended = true
        
        NSOperationQueue.mainQueue().cancelAllOperations()
        NSOperationQueue.mainQueue().suspended = true
    }
}
