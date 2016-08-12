//
//  NSOperationQueue+Queuable.swift
//  victorious
//
//  Created by Patrick Lynch on 2/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private let sharedOperationQueue = NSOperationQueue()

extension NSOperationQueue {
    
    /// An application-wide default queue for all operations that are not required to
    /// execute on the main queue.
    static var v_globalBackgroundQueue: NSOperationQueue {
        return sharedOperationQueue
    }
    
    func v_dependentOperationsOf(operation: NSOperation) -> [NSOperation] {
        return operations.filter { $0.dependencies.contains(operation) }
    }
    
    func v_rechainOperation( operation: NSOperation, after dependency: NSOperation ) {
        
        // Rechain (transfer) completion block
        operation.addDependency( dependency )
        
        // Rechain (transfer) dependencies
        for dependent in v_dependentOperationsOf( dependency ) {
            dependent.addDependency( operation )
        }
    }
}

extension NSOperationQueue {
    func v_addOperation<T: Queueable where T : NSOperation>( operation: T, completion: T.CompletionBlockType? ) {
        if let completion = completion {
            // Turn completion block into an operation.
            let completionOperation = NSBlockOperation() {
                operation.executeCompletionBlock(completion)
            }
            // For all other dependent operations of the current operation, make them dependent on the completion block operation instead.
            // This has to happen before we set up completion block operation's dependency to avoid a dead lock.
            v_dependentOperationsOf(operation).forEach { $0.addDependency(completionOperation) }
            
            // Set up dependency for completion block operation and add it to queue.
            completionOperation.addDependency(operation)
            addOperation(completionOperation)
        }
        addOperation(operation)
    }
}

class AsyncWaitingOperation: NSOperation, Queueable {
    
    // MARK: - Async
    
    func performUITask(task: () -> Void) {
        v_defaultQueue.suspended = true
        dispatch_async(dispatch_get_main_queue()) {
            task()
        }
    }
    
    func asyncCallBack() {
        v_defaultQueue.suspended = false
    }
    
    // MARK: - Queueable
    
    var error: NSError?
    
    func executeCompletionBlock(completionBlock: (NSError?, Bool) -> ()) {
        // This ensures that every subclass of `MainQueueOperation` has its completion block
        // executed on the main queue, which saves the trouble of having to wrap
        // in dispatch block in calling code.
        dispatch_async( dispatch_get_main_queue() ) {
            completionBlock(self.error, self.cancelled)
        }
    }
    
    override var v_defaultQueue: NSOperationQueue {
        // By overriding `defaultQueue` we are selecting the queue on which to add operations
        // when no other specifiec queue is provided by calling code.
        return NSOperationQueue.v_globalBackgroundQueue
    }
}

protocol Operation {
    associatedtype Completion
    
    func queue(completion completion: Completion?)
    func queue()
}

extension Operation {
    
    func queue() {
        queue(completion: nil)
    }
}

class SyncOperation<Output>: NSOperation, Operation {
    func execute() -> Output {
        fatalError()
    }
    
    var executeOnMainQueue: Bool {
        fatalError()
        return true
    }
    
    var queue: NSOperationQueue {
        return executeOnMainQueue ? .mainQueue() : .v_globalBackgroundQueue
    }
    
    private var output: Output?
    
    override func main() {
        output = execute()
    }
    
    func queue(completion completion: ((output: Output) -> Void)?) {
        queue.addOperation(self)
        
        if let completion = completion {
            queue.addOperationWithBlock {
                guard let output = self.output else {
                    assertionFailure("Received no output from sync operation to pass through the completion handler.")
                    return
                }
                
                completion(output: output)
            }
        }
    }
}

class AsyncOperation<Output>: NSOperation, Operation {
    func execute(finish: (output: Output) -> Void) {
        fatalError()
    }
    
    private let queue = NSOperationQueue.v_globalBackgroundQueue
    
    private var output: Output?
    
    var executeOnMainQueue: Bool {
        fatalError()
    }
    
    override final func main() {
        queue.suspended = true
        if executeOnMainQueue {
            dispatch_async(dispatch_get_main_queue()) {
                self.helper()
            }
        }
        else {
            helper()
        }
    }
    
    private func helper() {
        execute { output in
            self.output = output
            self.queue.suspended = false
        }
    }
    
    func queue(completion completion: ((output: Output) -> Void)?) {
        if let completion = completion {
            let completionOperation = NSBlockOperation {
                guard let output = self.output else {
                    assertionFailure("Received no output from async operation to pass through the completion handler.")
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(output: output)
                }
            }
            completionOperation.addDependency(self)
            queue.addOperation(completionOperation)
        }
        queue.addOperation(self)
    }
}
