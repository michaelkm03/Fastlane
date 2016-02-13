//
//  RequestOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import VictoriousCommon

class DefaultErrorHandler: RequestErrorHandler {
    
    let requestIdentifier: String
    var enabled: Bool = true
    
    init(requestIdentifier: String) {
        self.requestIdentifier = requestIdentifier
    }
    
    func handleError(error: NSError) -> Bool {
        VLog("RequestOperation `\(requestIdentifier)` failed with error: \(error)")
        return true
    }
}

class UnauthorizedErrorHandler: RequestErrorHandler {
    
    var enabled: Bool = true
    
    func handleError(error: NSError) -> Bool {
        if error.code == 401 {
            LogoutOperation().queue()
            return true
        }
        return false
    }
}

class RequestOperation: NSOperation, Queuable, ErrorOperation {
    
    internal(set) var results: [AnyObject]?
    
    private static let sharedQueue: NSOperationQueue = NSOperationQueue()
    
    var defaultQueue: NSOperationQueue { return RequestOperation.sharedQueue }
    
    var mainQueueCompletionBlock: ((NSError?)->())?
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    /// A place to store a background context so that it is retained for as long as expected during the operation
    var storedBackgroundContext: NSManagedObjectContext?
    
    lazy var requestExecutor: RequestExecutorType = MainRequestExecutor()
    
    // MARK: - Queuable
    
    var error: NSError? {
        return self.requestExecutor.error
    }
    
    func queueOn( queue: NSOperationQueue, completionBlock:((NSError?)->())?) {
        self.completionBlock = {
            guard !self.cancelled else {
                return
            }
            
            if completionBlock != nil {
                self.mainQueueCompletionBlock = completionBlock
            }
            dispatch_async( dispatch_get_main_queue()) {
                self.mainQueueCompletionBlock?( self.error )
            }
        }
        queue.addOperation( self )
    }
}
