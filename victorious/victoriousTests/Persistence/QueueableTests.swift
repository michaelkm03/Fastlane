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

private let _testQueue = NSOperationQueue()

class MockOperation: NSOperation, Queuable {

    static var sharedQueue: NSOperationQueue {
        return _testQueue
    }
    
    var label: String = ""
    var operationBlock: (@convention(block) (MockOperation)->())? = nil
    var testCompletionBlock: (@convention(block) (MockOperation)->())? = nil
    
    override init() {
        super.init()
    }
    
    init( _ label: String, block: (@convention(block) (MockOperation)->())? = nil ) {
        self.label = label
        self.operationBlock = block
    }
    
    private var result: Bool = false

    func queueOn( queue: NSOperationQueue, completionBlock: (@convention(block) (MockOperation)->())? ) {
        if let completionBlock = completionBlock {
            self.testCompletionBlock = completionBlock
        }
        self.completionBlock = {
            dispatch_async( dispatch_get_main_queue() ) {
                print( "\t\t >>>> >>> Completing operation: \(self.label) :: \(self.testCompletionBlock)")
                self.testCompletionBlock?( self )
            }
        }
        queue.addOperation(self)
    }
    
    override func main() {
        print( "\t\t >>>> >>> Performing operation: \(self.label)")
        dispatch_async( dispatch_get_main_queue() ) {
            self.operationBlock?(self)
            self.result = true
        }
    }
}

class QueueableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        MockOperation.sharedQueue.cancelAllOperations()
    }
    
    func testQueueOn() {
        let expectation = self.expectationWithDescription("testQueueOn")
        
        let operation = MockOperation("test") { op in
            XCTAssert( NSThread.currentThread().isMainThread )
        }
        operation.queueOn( NSOperationQueue.mainQueue() ) { op in
            XCTAssert( op.result )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testQueue() {
        let expectation = self.expectationWithDescription("testQueue")
        
        let operation = MockOperation()
        operation.queue() { op in
            XCTAssert( NSThread.currentThread().isMainThread )
            XCTAssert( op.result )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testQueueNoCompletion() {
        let expectation = self.expectationWithDescription("testQueueNoCompletion")
        
        let operation = MockOperation()
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            while !operation.finished {}
            XCTAssert( operation.result )
            expectation.fulfill()
        }
        operation.queue()
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testQueueAfterQueueBefore() {
        let expectation = self.expectationWithDescription("testQueueAfterQueueBefore")
        var completedOperations = [MockOperation]()

        let completionBlock: (MockOperation)->() = { op in
            XCTAssert( op.result )
            dispatch_async( dispatch_get_main_queue() ) {
                completedOperations.append( op )
                if completedOperations.count == 5 {
                    expectation.fulfill()
                }
            }
        }
        
        let queue = NSOperationQueue()
        
        let operationB = MockOperation("B")
        let operationA = MockOperation("A") { op in
            operationB.testCompletionBlock = completionBlock
            operationB.queueAfter( op, queue: queue )
        }
        let operationC = MockOperation("C")
        let operationD = MockOperation("D")
        let operationE = MockOperation("E")
        
        operationE.addDependency( operationC )
        operationC.addDependency( operationA )
        
        for op in [ operationA, operationC, operationE ] {
            op.queueOn( queue, completionBlock: completionBlock )
        }
        
        operationD.addDependency( operationC )
        operationD.testCompletionBlock = completionBlock
        operationD.queueBefore( operationE )
        
        waitForExpectationsWithTimeout(2, handler: nil)

        XCTAssertEqual( completedOperations.count, 5 )
        
        XCTAssertEqual( completedOperations[0].label, operationA.label )
        XCTAssertEqual( completedOperations[1].label, operationB.label )
        XCTAssertEqual( completedOperations[2].label, operationC.label )
        XCTAssertEqual( completedOperations[3].label, operationD.label )
        XCTAssertEqual( completedOperations[4].label, operationE.label )
    }
    
    func testDependentOperationsInQueue() {
        
        let queue = NSOperationQueue()
        let expectation = self.expectationWithDescription("testDependentOperationsInQueue")
        
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
            op.queueOn( queue )
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
