//
//  MainPersistentStoreTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class MainPersistentStoreTests: XCTestCase {
    
    let persistentStore: PersistentStoreType = MainPersistentStore()
    
    func testSyncBasic() {
        persistentStore.syncBasic() { context in
            XCTAssert( NSThread.currentThread().isMainThread )
        }
        
        let expectation = self.expectationWithDescription("testSyncBasic")
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            self.persistentStore.syncBasic() { context in
                XCTAssert( NSThread.currentThread().isMainThread )
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testSync() {
        let result: Bool = persistentStore.sync() { context in
            XCTAssert( NSThread.currentThread().isMainThread )
            return true
        }
        XCTAssert( result )
        
        let expectation = self.expectationWithDescription("testSync")
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            let result: Bool = self.persistentStore.sync() { context in
                XCTAssert( NSThread.currentThread().isMainThread )
                return true
            }
            XCTAssert( result )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testSyncFromBackground() {
        weak var expectation = self.expectationWithDescription("testSyncFromBackground")
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            self.persistentStore.syncFromBackground() { context in
                XCTAssertFalse( NSThread.currentThread().isMainThread )
                expectation?.fulfill()
            }
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAsyncFromBackground() {
        weak var expectation = self.expectationWithDescription("testAsyncFromBackground")
        persistentStore.asyncFromBackground() { context in
            XCTAssertFalse( NSThread.currentThread().isMainThread )
            dispatch_async( dispatch_get_main_queue() ) {
                expectation?.fulfill()
            }
        }
        waitForExpectationsWithTimeout(2) { error in }
    }
}
