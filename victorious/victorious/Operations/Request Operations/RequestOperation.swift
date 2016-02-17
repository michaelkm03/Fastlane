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

class RequestOperation: NSOperation, Queuable, ErrorOperation {
    
    internal(set) var results: [AnyObject]?
    
    private static let sharedQueue: NSOperationQueue = NSOperationQueue()
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    /// A place to store a background context so that it is retained for as long as expected during the operation
    var storedBackgroundContext: NSManagedObjectContext?
    
    lazy var requestExecutor: RequestExecutorType = MainRequestExecutor()
    
    override init() {
        super.init()
        
        requestExecutor.errorHandlers.append( UnauthorizedErrorHandler() )
        requestExecutor.errorHandlers.append( DefaultErrorHandler(requestIdentifier: "\(self.dynamicType)") )
    }
    
    /// Allows subclasses to override to disabled unauthorized (401) error handling.
    /// Otherwise, these errors are handled by default.
    var requiresAuthorization: Bool = true {
        didSet {
            if requiresAuthorization {
                if !requestExecutor.errorHandlers.contains({ $0 is UnauthorizedErrorHandler }) {
                    requestExecutor.errorHandlers.append( UnauthorizedErrorHandler() )
                }
            } else {
                requestExecutor.errorHandlers = requestExecutor.errorHandlers.filter { ($0 is UnauthorizedErrorHandler) == false }
            }
        }
    }
    
    // MARK: - ErrorOperation
    
    var error: NSError? {
        return self.requestExecutor.error
    }
    
    // MARK: - Queuable
    
    var defaultQueue: NSOperationQueue { return RequestOperation.sharedQueue }
    
    var mainQueueCompletionBlock: ((NSError?)->())?
    
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
