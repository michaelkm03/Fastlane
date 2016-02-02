//
//  FetcherOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An superclass for operations that use a paginator to fetch local results from the persistent store
class FetcherOperation: NSOperation, Queuable {
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    private static let sharedQueue: NSOperationQueue = NSOperationQueue()
    
    var results = [AnyObject]()
    
    var defaultQueue: NSOperationQueue { return FetcherOperation.sharedQueue }
    
    var mainQueueCompletionBlock: (([AnyObject]?, NSError?)->())?
    
    func queueOn( queue: NSOperationQueue, completionBlock:(([AnyObject]?, NSError?)->())?) {
        self.completionBlock = {
            if completionBlock != nil {
                self.mainQueueCompletionBlock = completionBlock
            }
            dispatch_async( dispatch_get_main_queue()) {
                let errorOperations = self.dependencies.flatMap { ($0 as? ErrorOperation)?.error }
                self.mainQueueCompletionBlock?( self.results, errorOperations.first )
            }
        }
        queue.addOperation( self )
    }
}
