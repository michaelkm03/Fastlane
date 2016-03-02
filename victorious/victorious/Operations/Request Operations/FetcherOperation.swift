//
//  FetcherOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import VictoriousCommon

class FetcherOperation: NSOperation, Queueable, ErrorOperation {
    
    var results: [AnyObject]?
    
    private static let sharedQueue: NSOperationQueue = NSOperationQueue()
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    /// A place to store a background context so that it is retained for as long as expected during the operation
    var storedBackgroundContext: NSManagedObjectContext?
    
    lazy var requestExecutor: RequestExecutorType = MainRequestExecutor()
    
    override init() {
        super.init()
        
        requestExecutor.errorHandlers.append( UnauthorizedErrorHandler() )
        requestExecutor.errorHandlers.append( DebugErrorHanlder(requestIdentifier: "\(self.dynamicType)") )
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
    
    // MARK: - Queueable
    
    func executeCompletionBlock(completionBlock: ([AnyObject]?, NSError?)->()) {

        // Calling the completion block on a cancelled requests can result in unexpected behaviour
        // since the reciver might not be in the right state to receive it.
        guard self.cancelled == false else {
            return
        }
        
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
    func queueWithCompletion(completion: (([AnyObject]?, NSError?)->())? = nil ) {
        queue(completion: completion)
    }
}
