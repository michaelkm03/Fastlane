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

/// An operation that executes a fetch request against the persistent store.
/// Subclasses of this operation primarily will fetch results from the persistent
/// store's main context to be returned to main thread calling code.
class FetcherOperation: NSOperation, Queueable, ResultsOperation {
    
    var localFetch: Bool = false
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    // MARK: - ResultsOperation
    
    var results: [AnyObject]?
    
    // MARK: - ErrorOperation
    
    var error: NSError?
    
    // MARK: - Queueable
    
    func executeCompletionBlock(completionBlock: ([AnyObject]?, NSError?, Bool) -> ()) {

        // Calling the completion block on a cancelled requests can result in unexpected behaviour
        // since the reciver might not be in the right state to receive it.
        guard self.cancelled == false else {
            return
        }
        
        // This ensures that every subclass of `FetcherOperation` has its completion block
        // executed on the main queue, which saves the trouble of having to wrap
        // in dispatch block in calling code.
        dispatch_async( dispatch_get_main_queue() ) {
            completionBlock(self.results, self.error, self.cancelled)
        }
    }
    
    /// A manual implementation of a method provided by a Swift protocol extension
    /// so that Objective-C can still easily queue and operation like other functions
    /// in the `Queueable` protocol.
    func queueWithCompletion(completion: (([AnyObject]?, NSError?, Bool) -> ())? = nil ) {
        queue(completion: completion)
    }
}
