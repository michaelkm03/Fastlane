//
//  NSOperation+Queue.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

protocol Queuable {
    
    /// The type of closure used for `completionBlock` properties that wil be called
    /// on the main queue when the operation is finished.
    typealias CompletionBlockType
    
    /// A queue selected by the receiver to be its perferred queue on which to execute.
    /// If you are doing something complex, you might pick whatever queue you like, but if
    /// you are unsure or have no reason not to, use this `defaultQueue` to execute the operation.
    var defaultQueue: NSOperationQueue { get }
    
    /// Queues the opration on the provided queue shared queue, then executes the completion
    /// block provides when the operation finishes.
    func queueOn( queue: NSOperationQueue, completionBlock:CompletionBlockType? )
    
    /// Queues the opration on the provided queue shared queue.
    func queueOn( queue: NSOperationQueue )
    
    /// Queues the opration on the receiver type's shared queue, then executes the completion
    /// block provides when the operation finishes.
    func queue( completionBlock:CompletionBlockType? )
    
    /// Queues the opration on the receiver type's shared queue.
    func queue()
    
    /// Queues the operation and sets it as a dependency of the receiver's dependent operations,
    /// effectively "cutting in line" all the dependency operations.  This allows operations to
    /// instantiate and queue a follow-up operation.
    /// Uses the queue provided.
    func queueAfter( operation: NSOperation, queue: NSOperationQueue )
    
    /// Queues the operation and sets it as a dependency of the receiver's dependent operations,
    /// effectively "cutting in line" all the dependency operations.  This allows operations to
    /// instantiate and queue a follow-up operation.
    /// Uses the shared queue for the type of the receiver.
    func queueAfter( operation: NSOperation )
    
    /// Queues the operation and sets it as a dependency of the receiver's dependent operations,
    /// effectively "cutting in line" all the dependency operations.  This allows operations to
    /// instantiate and queue a follow-up operation.
    /// Uses the shared queue for the type of the receiver.
    func queueBefore( operation: NSOperation )
    
    /// Queues the operation and sets it as a dependency of the receiver's dependent operations,
    /// effectively "cutting in line" all the dependency operations.  This allows operations to
    /// instantiate and queue a follow-up operation.
    /// Uses the queue provided.
    func queueBefore( operation: NSOperation, queue: NSOperationQueue )
    
    /// Returns an array of operations which are dependencies of the receiver on the provided queue.
    func dependentOperationsInQueue( queue: NSOperationQueue ) -> [NSOperation]
    
    func dependentOperationsInQueues( queues: [NSOperationQueue] ) -> [NSOperation]
    
    /// Returns an array of operations which are dependencies of the receiver on
    /// the shared queue for the type of the receiver.
    func dependentOperationsInQueue() -> [NSOperation]
}

/// Provides some defaults for NSOperation to support easily integration.
/// An NSOperation subclass need only to implemennt `queueOn(_:completionBlock:)` to support
/// all other methods in the Qeueuable protocol
extension Queuable where Self : NSOperation {
    
    func queueAfter( operation: NSOperation ) {
        queueAfter( operation, queue: self.defaultQueue )
    }
    
    func queueAfter( operation: NSOperation, queue: NSOperationQueue ) {
        let dependentOperations = (operation as? Self)?.dependentOperationsInQueue( queue ) ?? []
        for dependentOperation in dependentOperations {
            dependentOperation.addDependency( self )
        }
        addDependency( operation )
        queue.addOperation( self )
    }
    
    func queueBefore( operation: NSOperation ) {
        self.queueBefore( operation, queue: self.defaultQueue )
    }
    
    func queueBefore( operation: NSOperation, queue: NSOperationQueue ) {
        operation.addDependency( self )
        queue.addOperation( self )
    }
    
    func dependentOperationsInQueue( queue: NSOperationQueue ) -> [NSOperation] {
        return dependentOperationsInQueues( [queue] )
    }
    
    func dependentOperationsInQueues( queues: [NSOperationQueue] ) -> [NSOperation] {
        return queues.reduce( [NSOperation](), combine: { $0 + $1.operations.filter { $0.dependencies.contains(self) } } )
    }
    
    func dependentOperationsInQueue() -> [NSOperation] {
        return dependentOperationsInQueue( self.defaultQueue )
    }
    
    func queueOn( queue: NSOperationQueue ) {
        self.queueOn( queue, completionBlock: nil )
    }
    
    func queue( completionBlock:CompletionBlockType? ) {
        self.queueOn( self.defaultQueue, completionBlock: completionBlock )
    }
    
    func queue() {
        self.queueOn( self.defaultQueue, completionBlock: nil )
    }
}
