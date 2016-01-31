//
//  NavigationOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class NavigationOperation: NSOperation, Queuable {
    
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
    
    var defaultQueue: NSOperationQueue {
        return NSOperationQueue.mainQueue()
    }
    
    func queueOn( queue: NSOperationQueue, completionBlock:(()->())?) {
        self.completionBlock = completionBlock
        queue.addOperation( self )
    }
}
