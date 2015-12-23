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

class RequestOperationAlerts: NSObject {
    static let didReceiveAlertsNotification = "com.getvictorious.RequestOperation.AlertResult.didReceiveAlertsNotification"
    static let alertsKey = "com.getvictorious.RequestOperation.AlertResult.alertsKey"
    
    let alerts: [Alert]
    
    init(alerts: [Alert]) {
        self.alerts = alerts
    }
}

class RequestOperation: NSOperation, Queuable {
    
    static let errorDomain: String = "com.getvictorious.RequestOperation"
    static let errorCodeNoNetworkConnection: Int    = 9001
    static let errorCodeNoMoreResults: Int          = 9002
    
    var defaultQueue: NSOperationQueue { return _defaultQueue }
    
    static var sharedQueue: NSOperationQueue { return _defaultQueue }
    
    var mainQueueCompletionBlock: ((NSError?)->())?
    
    let persistentStore: PersistentStoreType = MainPersistentStore()
    let networkActivityIndicator = NetworkActivityIndicator.sharedInstance()
    
    private(set) var error: NSError?
    
    final func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())? = nil, onError: ((NSError, ()->())->())? = nil ) {
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(environment: currentEnvironment)
        let baseURL = currentEnvironment.baseURL
        
        let authenticationContext = persistentStore.mainContext.v_performBlockAndWait() { context in
            return AuthenticationContext(currentUser: VUser.currentUser())
        }
        
        let networkStatus = VReachability.reachabilityForInternetConnection().currentReachabilityStatus()
        if networkStatus == .NotReachable {
            let error = NSError(
                domain: RequestOperation.errorDomain,
                code: RequestOperation.errorCodeNoNetworkConnection,
                userInfo: nil
            )
            onError?( error, {} )
            
        } else {
            networkActivityIndicator.start()
            let executeSemphore = dispatch_semaphore_create(0)
            request.execute(
                baseURL: baseURL,
                requestContext: requestContext,
                authenticationContext: authenticationContext,
                callback: { (result, error, alerts) -> () in
                    dispatch_async( dispatch_get_main_queue() ) {
                        
                        // Handle alerts
                        let name = RequestOperationAlerts.didReceiveAlertsNotification
                        let userInfo = [ RequestOperationAlerts.alertsKey : RequestOperationAlerts(alerts: alerts) ]
                        NSNotificationCenter.defaultCenter().postNotificationName( name, object: nil, userInfo: userInfo)
                        
                        // Handle error
                        if let error = error as? RequestErrorType {
                            let nsError = NSError( error )
                            if let onError = onError {
                                onError( nsError ) {
                                    dispatch_semaphore_signal( executeSemphore )
                                }
                            } else {
                                dispatch_semaphore_signal( executeSemphore )
                            }
                        
                        // Handle result
                        } else if let requestResult = result {
                            if let onComplete = onComplete {
                                onComplete( requestResult ) {
                                    dispatch_semaphore_signal( executeSemphore )
                                }
                            } else {
                                dispatch_semaphore_signal( executeSemphore )
                            }
                        }
                    }
                }
            )
            dispatch_semaphore_wait( executeSemphore, DISPATCH_TIME_FOREVER )
            networkActivityIndicator.stop()
        }
    }
    
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
}
