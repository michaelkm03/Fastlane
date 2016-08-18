//
//  BackgroundOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// An operation designed for subclasses to perform background tasks.  The operation
/// can execute on a non-main queue, but its completion blocks of subclasses will
/// always execute on the main thread.
class BackgroundOperation: NSOperation, Queueable {
    
    private var _executing = false
    private var _finished = false
    
    var error: NSError?
    
    /// Subclasses that do not implement `main()` and need to maintain excuting state call this to move into an excuting state.
    final func beganExecuting() {
        executing = true
        finished = false
    }
    
    /// Subclasses that do not implement `main()` and need to maintain excuting state call this to move out of an executing state and are finished doing work.
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
    
    func executeCompletionBlock(completionBlock: (NSError?, Bool) -> ()) {
        // This ensures that every subclass of `BackgroundOperation` has its completion block
        // executed on the main queue, which saves the trouble of having to wrap
        // in dispatch block in calling code.
        dispatch_async( dispatch_get_main_queue() ) {
            completionBlock(self.error, self.cancelled)
        }
    }
    
    /// A manual implementation of a method provided by a Swift protocol extension
    /// so that Objective-C can still easily queue and operation like other functions
    /// in the `Queueable` protocol.
    func queueWithCompletion(completion: ((NSError?, Bool) -> ())? = nil) {
        queue(completion: completion)
    }
}
