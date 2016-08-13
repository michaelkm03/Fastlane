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
        let confirmation = MockActionConfirmationOperation(shouldConfirm: true)
        let operation = MockOperationWithPreconfrmation()
        operation.addDependency( confirmation )
        queue.addOperations( [confirmation, operation], waitUntilFinished: true )
        
        XCTAssert( operation.didExecute )
    }
    
    func testConfirmationNotConfirmed() {
        let confirmation = MockActionConfirmationOperation(shouldConfirm: false)
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
        let confirmation1 = MockActionConfirmationOperation(shouldConfirm: true)
        let confirmation2 = MockActionConfirmationOperation(shouldConfirm: true)
        let operation = MockOperationWithPreconfrmation()
        operation.addDependency( confirmation1 )
        operation.addDependency( confirmation2 )
        queue.addOperations( [confirmation1, confirmation2, operation], waitUntilFinished: true )
        
        XCTAssert( operation.didExecute )
    }
    
    func testConfirmationMixedConfirmed() {
        let confirmation1 = MockActionConfirmationOperation(shouldConfirm: true)
        let confirmation2 = MockActionConfirmationOperation(shouldConfirm: false)
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
