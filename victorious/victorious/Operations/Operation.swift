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
    
    private var _executing = false
    private var _finished = false
    
    /// Subclasses that do not implement `main()` and need to maintain excuting state call this to move into an excuting state.
    func beganExecuting () {
        executing = true
        finished = false
    }
    
    /// Subclasses that do not implement `main()` and need to maintain excuting state call this to move out of an executing state and are finished doing work.
    func finishedExecuting () {
        executing = false
        finished = true
    }
    
    // MARK: - KVO-able NSNotification State
    
    override var executing : Bool {
        get {return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished : Bool {
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
    
    func queueInBackground() {
        self.queueInBackground(nil)
    }
    
    func queueInBackground( completionMainQueueBlock:(()->())?) {
        self.completionBlock = {
            dispatch_async( dispatch_get_main_queue()) {
                completionMainQueueBlock?()
            }
        }
        Operation.defaultQueue.addOperation( self )
    }
    
    func queueNext( operation: NSOperation ) {
        for dependentOperation in dependencyOperations {
            dependentOperation.addDependency( operation )
        }
        Operation.defaultQueue.addOperation( operation )
    }
    
    var dependencyOperations: [NSOperation] {
        return Operation.defaultQueue.operations.filter { $0.dependencies.contains(self) }
    }
    
    func cancelAllOperations() {
        for operation in Operation.defaultQueue.operations {
            operation.cancel()
        }
    }
}
