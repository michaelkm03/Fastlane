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

class MockOperation: NSOperation, Queueable {

    static var sharedQueue: NSOperationQueue {
        return _testQueue
    }
    
    var operationBlock: (@convention(block) (MockOperation)->())? = nil
    var testCompletionBlock: (@convention(block) (MockOperation)->())? = nil
    
    override init() {
        super.init()
    }
    
    init( block: @convention(block) (MockOperation)->() ) {
        self.operationBlock = block
    }
    
    private var result: Bool = false

    func queueOn( queue: NSOperationQueue, completionBlock: (@convention(block) (MockOperation) -> ())? ) {
        if let completionBlock = completionBlock {
            self.testCompletionBlock = completionBlock
        }
        self.completionBlock = {
            dispatch_async( dispatch_get_main_queue() ) {
                self.testCompletionBlock?( self )
            }
        }
        queue.addOperation(self)
    }
    
    override func main() {
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
        let expectation = self.expectation(description:"testQueueOn")
        
        let operation = MockOperation() { op in
            XCTAssert( NSThread.currentThread().isMainThread )
        }
        operation.queueOn( NSOperationQueue.mainQueue() ) { op in
            XCTAssert( op.result )
            expectation.fulfill()
        }
        waitForExpectations(timeout:2, handler: nil)
    }
    
    func testQueue() {
        let expectation = self.expectation(description:"testQueue")
        
        let operation = MockOperation()
        operation.queue() { op in
            XCTAssert( NSThread.currentThread().isMainThread )
            XCTAssert( op.result )
            expectation.fulfill()
        }
        waitForExpectations(timeout:2, handler: nil)
    }
    
    func testQueueAfterQueueBefore() {
        let expectation = self.expectation(description:"testQueueAfterQueueBefore")
        var completedOperations = [MockOperation]()

        let completionBlock: (MockOperation)->() = { op in
            XCTAssert( op.result )
            completedOperations.append( op )
            if completedOperations.count == 5 {
                expectation.fulfill()
            }
        }
        
        let queue = NSOperationQueue()
        
        let operationB = MockOperation()
        operationB.testCompletionBlock = completionBlock
        let operationA = MockOperation() { op in
            operationB.queueAfter( op, queue: queue )
        }
        let operationC = MockOperation()
        let operationD = MockOperation()
        let operationE = MockOperation()
        
        operationE.addDependency( operationC )
        operationC.addDependency( operationA )
        
        for op in [ operationA, operationC, operationE ] {
            op.testCompletionBlock = completionBlock
            op.queueOn( queue )
        }
        
        operationD.addDependency( operationC )
        operationD.testCompletionBlock = completionBlock
        operationD.queueBefore( operationE )
        
        waitForExpectations(timeout:2, handler: nil)

        XCTAssertEqual( completedOperations.count, 5 )
        
        XCTAssertEqual( completedOperations[0], operationA )
        XCTAssertEqual( completedOperations[1], operationB )
        XCTAssertEqual( completedOperations[2], operationC )
        XCTAssertEqual( completedOperations[3], operationD )
        XCTAssertEqual( completedOperations[4], operationE )
    }
    
    func testDependentOperationsInQueue() {
        let queue = NSOperationQueue()
        
        let operationB = MockOperation()
        let operationC = MockOperation()
        let operationA = MockOperation()
        operationB.addDependency( operationA )
        operationC.addDependency( operationA )
        
        let dependentOperationsBefore = operationA.dependentOperationsInQueue( queue )
        XCTAssert( dependentOperationsBefore.isEmpty )

        for op in [ operationC, operationB, operationA ] {
            op.queueOn( queue )
        }

        let dependentOperations = operationA.dependentOperationsInQueue( queue )
        XCTAssertEqual( dependentOperations.count, 2 )
        XCTAssert( dependentOperations.contains(operationB) )
        XCTAssert( dependentOperations.contains(operationC) )
    }
}
