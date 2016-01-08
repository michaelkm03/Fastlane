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

private let _defaultQueue: NSOperationQueue = {
    var queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
}()

class RequestOperation: NSOperation, Queuable, RequestExecutorDelegate {
    
    static let errorDomain: String                  = "com.getvictorious.RequestOperation"
    static let errorCodeNoNetworkConnection: Int    = 9001
    static let errorCodeNoMoreResults: Int          = 9002
    
    var defaultQueue: NSOperationQueue { return _defaultQueue }
    
    static var sharedQueue: NSOperationQueue { return _defaultQueue }
    
    var mainQueueCompletionBlock: ((NSError?)->())?
    
    var alertsReceiver: AlertReceiver? = AlertReceiverSelector.defaultReceiver
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    lazy var requestExecutor: RequestExecutorType = {
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(environment: currentEnvironment)
        
        let authenticationContext = self.persistentStore.mainContext.v_performBlockAndWait() { context in
            return AuthenticationContext(currentUser: VCurrentUser.user())
        }
        
        var executor = MainRequestExecutor(
            baseURL: currentEnvironment.baseURL,
            requestContext: requestContext,
            authenticationContext: authenticationContext
        )
        executor.delegate = self
        return executor
    }()

    private(set) var error: NSError?
    
    // MARK: - Queuable
    
    func queueOn( queue: NSOperationQueue, completionBlock:((NSError?)->())?) {
        self.completionBlock = {
            if completionBlock != nil {
                self.mainQueueCompletionBlock = completionBlock
            }
            dispatch_async( dispatch_get_main_queue()) {
                self.mainQueueCompletionBlock?( self.error )
            }
        }
        queue.addOperation( self )
    }
    
    // MARK: - RequestExecutorDelegate
    
    func didReceiveAlerts( alerts: [Alert] ) {
        self.alertsReceiver?.onAlertsReceived( alerts )
    }
}
