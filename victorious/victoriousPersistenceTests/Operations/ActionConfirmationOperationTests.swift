//
//  ActionConfirmationOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ActionConfirmationOperationTests: XCTestCase {
    
    let queue = NSOperationQueue()
    
    func testConfirmationConfirmed() {
        let confirmation = MockConfirmationOperation(shouldConfirm: true)
        let operation = MockOperationWithPreconfrmation()
        operation.addDependency( confirmation )
        queue.addOperations( [confirmation, operation], waitUntilFinished: true )
        
        XCTAssert( operation.didExecute )
    }
    
    func testConfirmationNotConfirmed() {
        let confirmation = MockConfirmationOperation(shouldConfirm: false)
        let operation = MockOperationWithPreconfrmation()
        operation.addDependency( confirmation )
        queue.addOperations( [confirmation, operation], waitUntilFinished: true )
        
        XCTAssertFalse( operation.didExecute )
    }
    
    func testNoConfirmation() {
        let operation = MockOperationWithPreconfrmation()
        queue.addOperations( [operation], waitUntilFinished: true )
        XCTAssert( operation.didExecute )
    }
    
    func testConfirmationMultipleConfirmed() {
        let confirmation1 = MockConfirmationOperation(shouldConfirm: true)
        let confirmation2 = MockConfirmationOperation(shouldConfirm: true)
        let operation = MockOperationWithPreconfrmation()
        operation.addDependency( confirmation1 )
        operation.addDependency( confirmation2 )
        queue.addOperations( [confirmation1, confirmation2, operation], waitUntilFinished: true )
        
        XCTAssert( operation.didExecute )
    }
    
    func testConfirmationMixedConfirmed() {
        let confirmation1 = MockConfirmationOperation(shouldConfirm: true)
        let confirmation2 = MockConfirmationOperation(shouldConfirm: false)
        let operation = MockOperationWithPreconfrmation()
        operation.addDependency( confirmation1 )
        operation.addDependency( confirmation2 )
        queue.addOperations( [confirmation1, confirmation2, operation], waitUntilFinished: true )
        
        XCTAssertFalse( operation.didExecute )
    }
}

private class MockOperationWithPreconfrmation: NSOperation {
    
    var didExecute: Bool = false
    
    override func main() {
        guard didConfirmActionFromDependencies else {
            didExecute = false
            return
        }
        didExecute = true
    }
}

private class MockConfirmationOperation: NSOperation, ActionConfirmationOperation {
    
    var didConfirmAction: Bool = false
    
    let shouldConfirm: Bool
    
    init(shouldConfirm: Bool) {
        self.shouldConfirm = shouldConfirm
    }
    
    override func main() {
        didConfirmAction = shouldConfirm
    }
}
