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
    
    func rechainAfter(dependency: NSOperation) -> Self {
        addDependency(dependency)
        
        // Rechain (transfer) dependencies
        for dependent in dependency.dependentOperations {
            dependent.addDependency(self)
        }
        
        return self
    }
}

/// Future: 
/// This is the new Queueable protocol that will replace the original one.
/// Since FetcherOperation and FetcherRemoteOperatino still uses the original Queueable protocol,
/// we'll perform the replacement once core data is removed. Which I'll do next.
/// - note: No matter which queue the operation is scheduled and/or executed on, its completion block will be running on the main queue.
protocol Queueable2 {
    
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
    func queue(completion completion: ((result: OperationResult<Output>) -> Void)?)
    
    /// Adds the receiver to its default queue without completion block.
    func queue()
}

extension Queueable2 where Self: NSOperation {
    func queue(completion completion: ((result: OperationResult<Output>) -> Void)?) {
        defer {
            Queue.asyncSchedule.operationQueue.addOperation(self)
        }
        
        guard let completion = completion else {
            return
        }
        
        let completionOperation = NSBlockOperation {
            guard let result = self.result else {
                assertionFailure("Received no result from async operation to pass through the completion handler.")
                return
            }
            completion(result: result)
        }
        
        completionOperation.addDependency(self)
        NSOperationQueue.mainQueue().addOperation(completionOperation)
    }
    
    func queue() {
        queue(completion: nil)
    }
}

/// A synchronous operation runs its `execute` method synchronously on the provided `executionQueue` and finishes without waiting for any async callback.
/// - requires:
/// * Subclasses must override `var executionQueue` to specify which queue it gets executed on.
/// * Subclasses must override `func execute()` to specify the main body of the operation.
class SyncOperation<Output>: NSOperation, Queueable2 {
    
    // MARK: - Queueable2
    
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
    
    override final func main() {
        guard !cancelled else {
            result = .cancelled
            return
        }
        
        result = execute()
    }
}

private let asyncScheduleQueue = NSOperationQueue()

/// An asynchronous operation runs its `execute` method on the provided `executionQueue`, and then waits indefinitely for `finish` to be called.
/// Since it blocks the `scheduleQueue`, it is always scheduled on a separate global shared `asyncScheduleQueue`.
/// - requires:
/// * Subclasses must override `var executionQueue` to specify which queue it gets executed on.
/// * Subclasses must override `func execute()` to specify the main body of the operation.
/// - note:
/// * We use a semaphore to block the operation's execution, and only finishes when `finish` was called.
/// Semaphore blocks threads but not queues, so we may want to revisit this if something goes wrong / we need concurrent operations.
class AsyncOperation<Output>: NSOperation, Queueable2 {
    
    // MARK: - KVO-able NSNotification State
    
    private var _executing = false
    private var _finished = false
    
    final private func beganExecuting() {
        executing = true
        finished = false
    }
    
    final private func finishedExecuting() {
        executing = false
        finished = true
    }
    
    final override private(set) var executing: Bool {
        get {
            return _executing
        }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    final override private(set) var finished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    // MARK: - Queueable2
    
    let scheduleQueue = Queue.asyncSchedule
    
    var executionQueue: Queue {
        fatalError("Subclasses of AsyncOperation must override `executionQueue`!")
    }
    
    private(set) var result: OperationResult<Output>?
    
    // MARK: - Operation Execution
    
    func execute(finish: (result: OperationResult<Output>) -> Void) {
        fatalError("Subclasses of AsyncOperation must override `execute()`!")
    }
    
    override final func start() {
        guard !cancelled else {
            result = .cancelled
            finishedExecuting()
            return
        }
        
        beganExecuting()
        main()
    }
    
    override final func main() {
        executionQueue.operationQueue.addOperationWithBlock {
            self.execute { [weak self] result in
                defer {
                    self?.finishedExecuting()
                }
                guard let strongSelf = self else {
                    return
                }
                strongSelf.result = strongSelf.cancelled ? .cancelled : result
            }
        }
    }
}

/// This enum represents the result of executing an operation.
enum OperationResult<Output> {
    /// When the operation successfully finishes executing, and produces results of `Output` type. `Output` can be Void if no results is expected from the operation.
    case success(Output)
    /// When the operation failed with a specific error. Use this case when there's an error that should be surfaced to the user.
    case failure(ErrorType)
    /// When the operation was cancelled either by the caller, or determined to not be able to execute without a user facing error.
    case cancelled
}

enum Queue {
    case main
    case background
    case asyncSchedule
    
    static let allCases: [Queue] = [.main, .background, .asyncSchedule]
    
    static var allQueues: [NSOperationQueue] {
        return Queue.allCases.map { $0.operationQueue }
    }
    
    var operationQueue: NSOperationQueue {
        switch self {
            case .main: return NSOperationQueue.mainQueue()
            case .background: return NSOperationQueue.v_globalBackgroundQueue
            case .asyncSchedule: return asyncScheduleQueue
        }
    }
}
