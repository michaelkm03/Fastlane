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
    
    /// A queue to be shared by any object of the same type as the receiver.  If diferent types
    /// conforming to this protocol wish to share a queue, use the variants of `queue` that accept
    /// a queue as a parameter, or define a shared queue elsewhere that is merely returned from
    /// this computed property.
    static var sharedQueue: NSOperationQueue { get }
    
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
    
    /// Returns an array of operations which are dependencies of the receiver on
    /// the shared queue for the type of the receiver.
    func dependentOperationsInQueue() -> [NSOperation]
}

/// Provides some defaults for NSOperation to support easily integration.
/// An NSOperation subclass need only to implemennt `queueOn(_:completionBlock:)` to support
/// all other methods in the Qeueuable protocol
extension Queuable where Self : NSOperation {
    
    func queueAfter( operation: NSOperation ) {
        queueAfter( operation, queue: Self.sharedQueue )
    }
    
    func queueAfter( operation: NSOperation, queue: NSOperationQueue ) {
        for dependentOperation in (operation as? Self)?.dependentOperationsInQueue( queue ) ?? [] {
            dependentOperation.addDependency( self )
        }
        addDependency( operation )
        queue.addOperation( self )
    }
    
    func queueBefore( operation: NSOperation ) {
        self.queueBefore( operation, queue: Self.sharedQueue )
    }
    
    func queueBefore( operation: NSOperation, queue: NSOperationQueue ) {
        operation.addDependency( self )
        queue.addOperation( self )
    }
    
    func dependentOperationsInQueue( queue: NSOperationQueue ) -> [NSOperation] {
        return queue.operations.filter { $0.dependencies.contains(self) }
    }
    
    func dependentOperationsInQueue() -> [NSOperation] {
        return dependentOperationsInQueue( Self.sharedQueue )
    }
    
    func queueOn( queue: NSOperationQueue ) {
        self.queueOn( queue, completionBlock: nil )
    }
    
    func queue( completionBlock:CompletionBlockType? ) {
        self.queueOn( Self.sharedQueue, completionBlock: completionBlock )
    }
    
    func queue() {
        self.queueOn( Self.sharedQueue, completionBlock: nil )
    }
}
