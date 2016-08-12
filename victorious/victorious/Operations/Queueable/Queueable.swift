//
//  Queueable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension NSOperation {
    /// Allows operations to pick out a default queue that calling code can use
    /// to add operations when a more specialized queue is not needed.  May be
    /// overridden by subclasses to select a different queue as the default.
    var v_defaultQueue: NSOperationQueue {
        return NSOperationQueue.v_globalBackgroundQueue
    }
}

/// A customization designed for NSOperation that defines an object with
/// a completion block type specific to its purposes and some convenience
/// methods for adding it to an NSOperationQueue.
protocol Queueable {
    
    /// Conformers are required to define a completion block type that is
    /// specific to the actions it performs.  This allows calling code to have
    /// meaningful completion blocks that pass back results or other data.
    associatedtype CompletionBlockType
    
    /// Conformers must handle executing their own completion block in order
    /// to provide data typed to its signature.
    func executeCompletionBlock(completionBlock: CompletionBlockType)
    
    /// Adds the operation to the provided queue and sets up the typed completion
    /// block to be called from the standard ()->() block of NSOperation.
    func queueOn(queue: NSOperationQueue, completion: CompletionBlockType?)
    
    /// Adds the operation to `v_defaultQueue` and sets up the typed completion
    /// block to be called from the standard ()->() block of NSOperation.
    func queue(completion completion: CompletionBlockType?)
    
    /// Adds the operation to `v_defaultQueue` with no completion block.
    func queue()
}

/// Defines an object that offers a little twist on NSOperation's dependency API
/// with the purpose of composing operations into linear chain structures instead of
/// a branched tree structure.
protocol Chainable {
    
    /// Add the provided operation as a dependency to the receiver, i.e. the receiver
    /// becomes dependent and will not execute until the operation is finished.  Returns
    /// itself so that the operation can be modified or queued immediately after:
    /// `operationB.after(operationB).queue()`
    func after(dependency: NSOperation) -> Self
    
    /// Add the receiver as a dependency to the provided operation, i.e. the operation
    /// becomes dependent and will not execute until the receiver is finished.
    /// Returns itself so that the operation can be modified or queued immediately after:
    /// `operationA.before(operationB).queue()`
    func before(dependent: NSOperation) -> Self
    
    /// Add the provided operation as a dependency to the receiver, i.e. the operation
    /// becomes dependent and will not execute until the receiver is finished.  The receiver
    /// also takes on the completion block and any dependent operations in operation's
    /// `v_defaultQueue`, essentially "rechaining" the order of execution.
    func rechainAfter(dependency: NSOperation) -> Self
    
    /// Add the provided operation as a dependency to the receiver, i.e. the operation
    /// becomes dependent and will not execute until the receiver is finished.  The receiver
    /// also takes on the completion block and any dependent operations in the
    /// provided queue, essentially "rechaining" the order of execution.
    func rechainOn(queue: NSOperationQueue, after dependency: NSOperation) -> Self
}

extension Queueable where Self : NSOperation {
    
    func queue() {
        queue(completion: nil)
    }
    
    func queue(completion completion: CompletionBlockType?) {
        queueOn(v_defaultQueue, completion: completion)
    }
    
    func queueOn(queue: NSOperationQueue, completion: CompletionBlockType?) {
        queue.v_addOperation(self, completion: completion)
    }
}

extension NSOperation: Chainable {
    
    func after(dependency: NSOperation) -> Self {
        addDependency(dependency)
        return self
    }
    
    func before(dependent: NSOperation) -> Self {
        dependent.addDependency(self)
        return self
    }
    
    func rechainOn(queue: NSOperationQueue, after dependency: NSOperation) -> Self {
        queue.v_rechainOperation(self, after: dependency)
        return self
    }
    
    func rechainAfter(dependency: NSOperation) -> Self {
        return rechainOn(v_defaultQueue, after: dependency)
    }
}

/// This is designed to be a simplified version of Queueable and will replace it.
/// Since FetcherOperation and FetcherRemoteOperatino still uses the original Queueable protocol,
/// we'll perform the replacement once core data is removed. Which I'll do next.
protocol Queueable2 {
    
    /// Conformers are required to define a completion block type that is
    /// specific to the actions it performs.  This allows calling code to have
    /// meaningful completion blocks that pass back results or other data.
    associatedtype Completion
    
    /// Conformers should define what type of Output it will generate.
    associatedtype Output
    
    /// The output generated by the operation.
    var output: Output? { get }
    
    /// Conformers should speficy which queue the operation should be scheduled(queued) on.
    var scheduleQueue: NSOperationQueue { get }
    
    /// Adds the receiver to its default queue, with a completion block that'll run after the receiver's finished executing,
    /// and before the next operation starts.
    func queue(completion completion: Completion?)
    
    /// Adds the receiver to its default queue without completion block.
    func queue()
}

extension Queueable2 where Self: NSOperation {
    func queue(completion completion: ((output: Output) -> Void)?) {
        defer {
            scheduleQueue.addOperation(self)
        }
        
        guard let completion = completion else {
            return
        }
        
        let completionOperation = NSBlockOperation {
            guard let output = self.output else {
                assertionFailure("Received no output from async operation to pass through the completion handler.")
                return
            }
            completion(output: output)
        }
        
        completionOperation.addDependency(self)
        NSOperationQueue.mainQueue().addOperation(completionOperation)
    }
    
    func queue() {
        queue(completion: nil)
    }
}

/// A synchronous operation runs its execute() block and finish executing without waiting for any async callback.
/// - note: 
/// - Subclasses must override `var scheduleQueue` to specify which queue it gets scheduled and executed on.
/// - Subclasses must override `func execute()` to specify the main body of the operation.
class SyncOperation<Output>: NSOperation, Queueable2 {
    
    // MARK: - Queueable2
    
    var scheduleQueue: NSOperationQueue {
        fatalError()
    }
    
    private(set) var output: Output?
    
    // MARK: - Operation Execution
    
    func execute() -> Output {
        fatalError()
    }
    
    override final func main() {
        output = execute()
    }
}

private let asyncScheduleQueue = NSOperationQueue()

/// A asynchronous operation runs its execute() block and finish executing, suspend the queue it is scheduled on, and execute completion block after the async callback. Since it blocks the `scheduleQueue`, it is always scheduled on a separate global shared `asyncScheduleQueue`.
/// - note:
/// - Subclasses must override `var executionQueue` to specify which queue it gets executed on.
/// - Subclasses must override `func execute()` to specify the main body of the operation.
class AsyncOperation<Output>: NSOperation, Queueable2 {
    
    // MARK: - Queueable2
    
    let queue = NSOperationQueue.v_globalBackgroundQueue
    
    let scheduleQueue = asyncScheduleQueue
    
    private(set) var output: Output?
    
    // MARK: - Operation Execution
    
    var executionQueue: NSOperationQueue {
        fatalError()
    }
    
    func execute(finish: (output: Output) -> Void) {
        fatalError()
    }
    
    override final func main() {
        let executeSemphore = dispatch_semaphore_create(0)
        executionQueue.addOperationWithBlock {
            self.execute { output in
                self.output = output
                dispatch_semaphore_signal(executeSemphore)
            }
        }
        dispatch_semaphore_wait(executeSemphore, DISPATCH_TIME_FOREVER)
    }
}
