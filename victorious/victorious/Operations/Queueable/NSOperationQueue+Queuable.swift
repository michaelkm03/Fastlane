//
//  NSOperationQueue+Queuable.swift
//  victorious
//
//  Created by Patrick Lynch on 2/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private let _sharedOperationQueue = NSOperationQueue()

extension NSOperationQueue {
    
    /// An application-wide default queue for all operations that are not required to
    /// execute on the main queue.
    static var v_globalBackgroundQueue: NSOperationQueue {
        return _sharedOperationQueue
    }
    
    func v_dependentOperationsOf(operation: NSOperation) -> [NSOperation] {
        return operations.filter { $0.dependencies.contains(operation) }
    }
    
    func v_addOperation( operation: NSOperation, completion: (()->())? ) {
        operation.completionBlock = completion
        addOperation( operation )
    }
    
    func v_rechainOperation( operation: NSOperation, after dependency: NSOperation ) {
        
        // Rechain (transfer) completion block
        operation.addDependency( dependency )
        operation.completionBlock = dependency.completionBlock
        dependency.completionBlock = nil
        
        // Rechain (transfer) dependencies
        for dependent in v_dependentOperationsOf( dependency ) {
            dependent.addDependency( operation )
        }
    }
    
    func v_chainOperations( operations: [NSOperation], completion:(()->())? = nil  ) {
        var lastOp: NSOperation?
        for nextOp in operations {
            if let lastOp = lastOp {
                nextOp.addDependency(lastOp)
            }
            lastOp = nextOp
        }
        operations.last?.completionBlock = completion
    }
    
    func v_queueChainedOperations( operations: [NSOperation], completion:(()->())? = nil ) {
        v_chainOperations( operations, completion: completion )
        addOperations( operations, waitUntilFinished: false )
    }
}

extension NSOperationQueue {
    
    func v_addOperation<T: QueueableOperation where T : NSOperation>( operation: T, completion: T.CompletionBlockType? ) {
        if let completion = completion {
            operation.completionBlock = { [weak operation] in
                operation?.executeCompletionBlock(completion)
            }
        }
        addOperation( operation )
    }
}
