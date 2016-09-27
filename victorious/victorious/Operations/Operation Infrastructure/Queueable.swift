//
//  Queueable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// - note: No matter which queue the operation is scheduled and/or executed on, its completion block will be running on the main queue.
protocol Queueable {
    /// Conformers should define what type of Output it will generate.
    associatedtype Output
    
    /// The result of executing the operation.
    /// This is optional because we don't have the result at initialization time.
    /// Conformers should verify this has been set before calling completion block.
    var result: OperationResult<Output>? { get }
    
    /// Conformers should specify which queue the operation itself should be scheduled(queued) on.
    var scheduleQueue: Queue { get }
    
    /// Conformers should specify which queue the operation's code should be executed on.
    var executionQueue: Queue { get }
    
    /// Adds the receiver to its default queue, with a completion block that'll run after the receiver's finished executing,
    /// and before the next operation starts.
    func queue(completion: ((_ result: OperationResult<Output>) -> Void)?)
    
    /// Adds the receiver to its default queue without completion block.
    func queue()
}

extension Queueable where Self: Operation {
    func queue(completion: ((_ result: OperationResult<Output>) -> Void)?) {
        defer {
            scheduleQueue.operationQueue.addOperation(self)
        }
        
        guard let completion = completion else {
            return
        }
        
        let completionOperation = BlockOperation {
            guard let result = self.result else {
                Log.error("Received no result from async operation to pass through the completion handler. Operation: \(self)")
                return
            }
            completion(result)
        }
        
        completionOperation.addDependency(self)
        OperationQueue.main.addOperation(completionOperation)
    }
    
    func queue() {
        queue(completion: nil)
    }
}
