//
//  Operation.swift
//  victorious
//
//  Created by Michael Sena on 8/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class Operation: NSOperation {
    
    static let defaultQueue = NSOperationQueue()
    
    var mainQueueCompletionBlock: (()->())?
    
    private var _executing = false
    private var _finished = false
    
    /// Subclasses that do not implement `main()` and need to maintain excuting state call this to move into an excuting state.
    final func beganExecuting () {
        executing = true
        finished = false
    }
    
    /// Subclasses that do not implement `main()` and need to maintain excuting state call this to move out of an executing state and are finished doing work.
    final func finishedExecuting () {
        executing = false
        finished = true
    }
    
    // MARK: - KVO-able NSNotification State
    
   final override var executing : Bool {
        get {return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    final override var finished: Bool {
        get {return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    class func sharedQueue() -> NSOperationQueue {
        return Operation.defaultQueue
    }
    
    final func queue() {
        self.queue(nil)
    }
    
    final func queueOn( queue: NSOperationQueue, mainQueueCompletionBlock:(()->())?) {
        self.completionBlock = {
            if mainQueueCompletionBlock != nil {
                self.mainQueueCompletionBlock = mainQueueCompletionBlock
            }
            dispatch_async( dispatch_get_main_queue()) {
                self.mainQueueCompletionBlock?()
            }
        }
        queue.addOperation( self )
    }
    
    final func queue( completion:(()->())?) {
        self.queueOn( Operation.defaultQueue, mainQueueCompletionBlock: completion )
    }
}

extension NSOperation {
    
    /// Queues the operation and sets it as a dependency of the receiver's dependent operations,
    /// effectively "cutting in line" all the dependency operations.  This allows operations to
    /// instantiate and queue a follow-up operation.
    func queueNext( operation: NSOperation, queue: NSOperationQueue ) {
        for dependentOperation in dependentOperationsInQueue( queue ) {
            dependentOperation.addDependency( operation )
        }
        queue.addOperation( operation )
    }
    
    /// Returns an array of operations which are dependencies of the receiver
    func dependentOperationsInQueue( queue: NSOperationQueue) -> [NSOperation] {
        return queue.operations.filter { $0.dependencies.contains(self) }
    }
}
