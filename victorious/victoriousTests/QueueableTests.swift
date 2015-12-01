//
//  QueueableTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import Foundation
@testable import victorious

class QueueableTests: XCTestCase {
    
    /*func testQueueOn() {
        let expectation = self.expectationWithDescription("testQueueOn")
        
        let operation = MockOperation("test") { op in
            XCTAssert( NSThread.currentThread().isMainThread )
        }
        operation.queueOn( NSOperationQueue.mainQueue() ) { op in
            XCTAssert( op.finished )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testQueue() {
        let expectation = self.expectationWithDescription("testQueue")
        
        let operation = MockOperation()
        operation.queue() { op in
            XCTAssert( op.finished )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testQueueNoCompletion() {
        let expectation = self.expectationWithDescription("testQueueNoCompletion")
        
        let operation = MockOperation()
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            while !operation.finished {}
            XCTAssert( operation.finished )
            expectation.fulfill()
        }
        operation.queue()
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testQueueAfterQueueBefore() {
        let expectation = self.expectationWithDescription("testQueueAfterQueueBefore")
        var completedOperations = [MockOperation]()

        let completionBlock: (MockOperation)->() = { op in
            XCTAssert( op.finished )
            dispatch_async( dispatch_get_main_queue() ) {
                completedOperations.append( op )
                if completedOperations.count == 5 {
                    expectation.fulfill()
                }
            }
        }
        
        let queue = NSOperationQueue()
        
        let operationB = MockOperation("B")
        let operationA = MockOperation("A")
        let operationC = MockOperation("C")
        let operationD = MockOperation("D")
        let operationE = MockOperation("E")
        
        operationE.addDependency( operationC )
        operationC.addDependency( operationA )
        
        for op in [ operationC, operationE ] {
            op.queueOn( queue, completionBlock: completionBlock )
        }

        operationA.queue() { op in
            operationB.queueAfter( op, queue: queue, completionBlock: completionBlock )
            completionBlock(op)
        }
        
        operationD.addDependency( operationC )
        operationD.queueBefore( operationE, completionBlock: completionBlock )
        
        waitForExpectationsWithTimeout(2, handler: nil)
        
        XCTAssertEqual( completedOperations[0].label, operationA.label )
        XCTAssertEqual( completedOperations[1].label, operationB.label )
        XCTAssertEqual( completedOperations[2].label, operationC.label )
        XCTAssertEqual( completedOperations[3].label, operationD.label )
        XCTAssertEqual( completedOperations[4].label, operationE.label )
    }
    
    func testDependentOperationsInQueue() {
        
        let queue = NSOperationQueue()
        let expectation = self.expectationWithDescription("test_dependentOperationsInQueue")
        
        let operationB = MockOperation("B")
        let operationC = MockOperation("C")
        
        let operationA = MockOperation("A") { op in
            let dependentOperations = op.dependentOperationsInQueue( queue )
            XCTAssertEqual( dependentOperations.count, 2 )
            XCTAssertEqual( (dependentOperations[0] as! MockOperation).label, operationB.label )
            XCTAssertEqual( (dependentOperations[1] as! MockOperation).label, operationC.label )
            expectation.fulfill()
        }
        
        operationB.addDependency( operationA )
        operationC.addDependency( operationA )
        
        let dependentOperationsBefore = operationA.dependentOperationsInQueue( queue )
        XCTAssert( dependentOperationsBefore.isEmpty )

        for op in [ operationA, operationB, operationC ] {
            op.queueOn( queue, completionBlock: nil )
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }*/
}
