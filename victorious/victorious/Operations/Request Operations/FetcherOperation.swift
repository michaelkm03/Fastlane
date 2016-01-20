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
    
    var mainQueueCompletionBlock: (([AnyObject])->())?
    
    func queueOn( queue: NSOperationQueue, completionBlock:(([AnyObject])->())?) {
        self.completionBlock = {
            if completionBlock != nil {
                self.mainQueueCompletionBlock = completionBlock
            }
            dispatch_async( dispatch_get_main_queue()) {
                self.mainQueueCompletionBlock?(self.results)
            }
        }
        queue.addOperation( self )
    }
    
    func newObjectDisplayOrder( entityName: String, context: NSManagedObjectContext, predicate: NSPredicate ) -> Int {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        fetchRequest.fetchLimit = 1
        guard let lowestDisplayOrderObject = context.v_executeFetchRequest( fetchRequest ).first as? PaginatedObjectType else {
            return -1
        }
        return (lowestDisplayOrderObject.displayOrder?.integerValue ?? 0) - 1
    }
}
