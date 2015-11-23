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

let _testQueue = NSOperationQueue()

class MockOperation: NSOperation, Queuable {

    static var sharedQueue: NSOperationQueue {
        return _testQueue
    }
    
    var label: String = ""
    var operationBlock: ((MockOperation)->())? = nil
    var testCompletionBlock: ((MockOperation)->())? = nil {
        didSet {
            self.completionBlock = {
                self.testCompletionBlock?(self)
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    init( _ label: String, block:((MockOperation)->())? = nil ) {
        self.label = label
        self.operationBlock = block
    }
    
    private var result: Bool = false

    func queueOn( queue: NSOperationQueue, completionBlock:((MockOperation)->())? ) {
        self.completionBlock = {
            completionBlock?( self )
        }
        queue.addOperation(self)
    }
    
    override func main() {
        self.operationBlock?(self)
        self.result = true
    }
}

class QueueableTests: XCTestCase {
    
    func test_queueOn() {
        let expectation = self.expectationWithDescription("test_queueOn")
        
        let operation = MockOperation("test") { op in
            XCTAssert( NSThread.currentThread().isMainThread )
        }
        operation.queueOn( NSOperationQueue.mainQueue() ) { op in
            XCTAssert( op.result )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func test_queue() {
        let expectation = self.expectationWithDescription("test_queue")
        
        let operation = MockOperation()
        operation.queue() { op in
            XCTAssertFalse( NSThread.currentThread().isMainThread )
            XCTAssert( op.result )
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func test_queueNoCompletion() {
        let expectation = self.expectationWithDescription("test_queue")
        
        let operation = MockOperation()
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
            while !operation.finished {}
            XCTAssert( operation.result )
            expectation.fulfill()
        }
        operation.queue()
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func test_queueAfter_queueBefore() {
        let expectation = self.expectationWithDescription("test_queueAfter_queueBefore")
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
        
        XCTAssertEqual( completedOperations[0].label, operationA.label )
        XCTAssertEqual( completedOperations[1].label, operationB.label )
        XCTAssertEqual( completedOperations[2].label, operationC.label )
        XCTAssertEqual( completedOperations[3].label, operationD.label )
        XCTAssertEqual( completedOperations[4].label, operationE.label )
    }
    
    func test_dependentOperationsInQueue() {
        
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
            op.queueOn( queue )
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
