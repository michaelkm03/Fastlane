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

private let _defaultQueue: NSOperationQueue = NSOperationQueue()

class RequestOperation: NSOperation, Queuable {
    
    static let errorDomain: String = "com.getvictorious.RequestOperation"
    static let errorCodeNoNetworkConnection: Int    = 9001
    static let errorCodeNoMoreResults: Int          = 9002
    
    var defaultQueue: NSOperationQueue { return _defaultQueue }
    
    static var sharedQueue: NSOperationQueue { return _defaultQueue }
    
    var mainQueueCompletionBlock: ((NSError?)->())?
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.mainPersistentStore
    
    /// A place to store a background context so that it is retained for as long as expected during the operation
    var storedBackgroundContext: NSManagedObjectContext?
    
    lazy var requestExecutor: RequestExecutorType = {
        return MainRequestExecutor(persistentStore: self.persistentStore)
    }()
    
    // MARK: - Queuable
    
    func queueOn( queue: NSOperationQueue, completionBlock:((NSError?)->())?) {
        self.completionBlock = {
            if completionBlock != nil {
                self.mainQueueCompletionBlock = completionBlock
            }
            dispatch_async( dispatch_get_main_queue()) {
                self.mainQueueCompletionBlock?( self.requestExecutor.error )
            }
        }
        queue.addOperation( self )
    }
}
