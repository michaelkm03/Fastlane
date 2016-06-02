//
//  MainQueueOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An operation that performs view controller navigations or other UI work.
/// Using assertions and customized implementation of `Qeueuable`, all code
/// in the `main()` function and completion blocks are guaranteed to only
/// ever run on the main thread.
class MainQueueOperation: NSOperation, Queueable {
    
    var error: NSError?
    
    private var _executing = false
    private var _finished = false
    
    /// Subclasses that do not implement `main()` and need to maintain executing
    /// state call this to move into an executing state.
    final func beganExecuting() {
        executing = true
        finished = false
    }
    
    /// Subclasses that do not implement `main()` and need to maintain executing
    /// state call this to move out of an executing state and are finished doing work.
    final func finishedExecuting() {
        executing = false
        finished = true
    }
    
    // MARK: - KVO-able NSNotification State
    
    final override var executing: Bool {
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
    
    // MARK: - Queueable
    
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
        return NSOperationQueue.mainQueue()
    }
    
    /// A manual implementation of a method provided by a Swift protocol extension
    /// so that Objective-C can still easily queue and operation like other functions
    /// in the `Queueable` protocol.
    func queueWithCompletion(completion: ((NSError?, Bool) -> ())? = nil) {
        queue(completion: completion)
    }
}
