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
    typealias CompletionBlockType
    
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
