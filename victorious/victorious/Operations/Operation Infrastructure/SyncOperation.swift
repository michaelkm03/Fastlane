//
//  SyncOperation.swift
//  victorious
//
//  Created by Jarod Long on 9/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A synchronous operation runs its `execute` method synchronously on the provided `executionQueue` and finishes without waiting for any async callback.
/// - requires:
/// * Subclasses must override `var executionQueue` to specify which queue it gets executed on.
/// * Subclasses must override `func execute()` to specify the main body of the operation.
class SyncOperation<Output>: NSOperation, Queueable {
    
    // MARK: - Queueable
    
    final var scheduleQueue: Queue {
        return executionQueue
    }
    
    var executionQueue: Queue {
        fatalError("Subclasses of SyncOperation must override `executionQueue`!")
    }
    
    private(set) var result: OperationResult<Output>?
    
    // MARK: - Operation Execution
    
    func execute() -> OperationResult<Output> {
        fatalError("Subclasses of SyncOperation must override `execute()`!")
    }
    
    override func cancel() {
        super.cancel()
        result = .cancelled
    }
    
    override final func main() {
        guard !cancelled else {
            result = .cancelled
            return
        }
        
        result = execute()
    }
}
