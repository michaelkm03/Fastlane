//
//  Operation.swift
//  victorious
//
//  Created by Michael Sena on 8/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class Operation: NSOperation, Queuable {
    
    var mainQueueCompletionBlock: ((Operation)->())?
    
    static let defaultQueue = NSOperationQueue()
    static var sharedQueue: NSOperationQueue {
        return Operation.defaultQueue
    }
    
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
    
    // MARK: - Queuable
    
    func queueOn( queue: NSOperationQueue, completionBlock:((Operation)->())?) {
        self.completionBlock = {
            if completionBlock != nil {
                self.mainQueueCompletionBlock = completionBlock
            }
            dispatch_async( dispatch_get_main_queue()) {
                self.mainQueueCompletionBlock?( self )
            }
        }
        queue.addOperation( self )
    }
}
