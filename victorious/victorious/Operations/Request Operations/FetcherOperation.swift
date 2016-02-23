//
//  FetcherOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An superclass for operations that use a paginator to fetch local results from the persistent store
class FetcherOperation: NSOperation, Queueable, ResultsOperation {
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    private static let sharedQueue: NSOperationQueue = NSOperationQueue()
    
    // MARK: - ResultsOperation
    
    var results: [AnyObject]?
    
    // MARK: - ErrorOperation
    
    var error: NSError?
    
    // MARK: - Queueable
    
    func executeCompletionBlock(completionBlock: ([AnyObject]?, NSError?)->()) {
        // This ensures that every subclass of `FetcherOperation` has its completion block
        // executed on the main queue, which saves the trouble of having to wrap
        // in dispatch block in calling code.
        dispatch_async( dispatch_get_main_queue() ) {
            completionBlock(self.results, self.error)
        }
    }
    
    /// A manual implementation of a method provided by a Swift protocol extension
    /// so that Objective-C can still easily queue and operation like other functions
    /// in the `Queueable` protocol.
    func queueWithCompletion(completion: ([AnyObject]?, NSError?)->()) {
        queue(completion: completion)
    }
}
