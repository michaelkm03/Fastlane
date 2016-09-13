//
//  AsyncOperation.swift
//  victorious
//
//  Created by Jarod Long on 9/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An asynchronous operation runs its `execute` method on the provided `executionQueue`, and then waits indefinitely for `finish` to be called.
/// Since it blocks the `scheduleQueue`, it is always scheduled on a separate global shared `asyncScheduleQueue`.
/// - requires:
/// * Subclasses must override `var executionQueue` to specify which queue it gets executed on.
/// * Subclasses must override `func execute()` to specify the main body of the operation.
/// - note:
/// * The operation will block its `executionQueue` only during the synchronous execution of the `execute` method.
class AsyncOperation<Output>: NSOperation, Queueable {
    
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
    
    // MARK: - Queueable
    
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
