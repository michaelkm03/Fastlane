//
//  MainPersistentStoreTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import CoreData
@testable import victorious

class MainPersistentStoreTests: XCTestCase {
    
    let persistentStore: PersistentStoreType = PersistentStoreSelector.mainPersistentStore

    var storedBackgroundContext: NSManagedObjectContext?
    
    func testSyncBasic() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            XCTAssert( NSThread.currentThread().isMainThread )
        }
        
        let expectation = self.expectationWithDescription("testSyncBasic")
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            self.persistentStore.mainContext.v_performBlockAndWait() { context in
                XCTAssertEqual( context, self.persistentStore.mainContext )
                XCTAssert( NSThread.currentThread().isMainThread )
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testSync() {
        let result: Bool = persistentStore.mainContext.v_performBlockAndWait() { context in
            XCTAssert( NSThread.currentThread().isMainThread )
            return true
        }
        XCTAssert( result )
        
        let expectation = self.expectationWithDescription("")
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            let result: Bool = self.persistentStore.mainContext.v_performBlockAndWait() { context in
                XCTAssertEqual( context, self.persistentStore.mainContext )
                XCTAssert( NSThread.currentThread().isMainThread )
                return true
            }
            XCTAssert( result )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testSyncFromBackground() {
        let expectation = self.expectationWithDescription("")
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            let backgroundContext = self.persistentStore.createBackgroundContext()
            backgroundContext.v_performBlockAndWait() { context in
                XCTAssertEqual( context, backgroundContext )
                XCTAssertFalse( NSThread.currentThread().isMainThread )
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAsyncFromBackground() {
        let expectation = self.expectationWithDescription("")
        let backgroundContext = self.persistentStore.createBackgroundContext()
        backgroundContext.v_performBlock() { context in
            XCTAssertFalse( NSThread.currentThread().isMainThread )
            XCTAssertEqual( context, backgroundContext )
            dispatch_async( dispatch_get_main_queue() ) {
                expectation.fulfill()
            }
        }
       waitForExpectationsWithTimeout(2, handler: nil)
    }
}
