//
//  NSOperationQueue+Queuable.swift
//  victorious
//
//  Created by Patrick Lynch on 2/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSOperationQueue {
    func v_addOperation<T: Queueable where T : NSOperation>( operation: T, completion: T.CompletionBlockType? ) {
        if let completion = completion {
            // Turn completion block into an operation. 
            // This ensures that any dependent operations start executing after the completio block gets executed.
            let completionOperation = NSBlockOperation() {
                operation.executeCompletionBlock(completion)
            }
            // For all other dependent operations of the current operation, make them dependent on the completion block operation instead.
            // This has to happen before we set up completion block operation's dependency to avoid a dead lock.
            operation.dependentOperations.forEach { $0.addDependency(completionOperation) }
            
            // Set up dependency for completion block operation and add it to queue.
            completionOperation.addDependency(operation)
            addOperation(completionOperation)
        }
        addOperation(operation)
    }
}
