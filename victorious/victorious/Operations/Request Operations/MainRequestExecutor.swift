//
//  MainRequestExecutor.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// A class wrapper for an array of `Alert` structs so that they can be passed through
/// Objective-C runtime infrastructure such as `NSNotificationCenter`.
class AlertObject: NSObject {
    
    static let didReceiveAlertsNotification = "com.getvictorious.MainRequestExecutor.didReceiveAlertsNotification"
    static let alertsKey = "com.getvictorious.MainRequestExecutor.alertsKey"
    
    let sourceAlert: Alert
    
    init(sourceAlert: Alert) {
        self.sourceAlert = sourceAlert
    }
}

struct MainRequestExecutor: RequestExecutorType {
    
    private let persistentStore: PersistentStoreType
    private let networkActivityIndicator = NetworkActivityIndicator.sharedInstance()
    
    private var hasNetworkConnection: Bool {
        return VReachability.reachabilityForInternetConnection().currentReachabilityStatus() != .NotReachable
    }
    
    init(persistentStore: PersistentStoreType) {
        self.persistentStore = persistentStore
    }
    
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?) {
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(environment: currentEnvironment)
        let baseURL = currentEnvironment.baseURL
        
        let authenticationContext = persistentStore.mainContext.v_performBlockAndWait() { context in
            return AuthenticationContext(currentUser: VCurrentUser.user())
        }
        
        if !hasNetworkConnection {
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
                        
                        if !alerts.isEmpty {
                            let alertObjects = alerts.map { AlertObject(sourceAlert: $0) }
                            let userInfo = [ AlertObject.alertsKey : alertObjects ];
                            NSNotificationCenter.defaultCenter().postNotificationName(
                                AlertObject.didReceiveAlertsNotification,
                                object: nil,
                                userInfo: userInfo
                            )
                        }
                        
                        if let error = error as? RequestErrorType {
                            let nsError = NSError( error )
                            if let onError = onError {
                                onError( nsError ) {
                                    dispatch_semaphore_signal( executeSemphore )
                                }
                            } else {
                                dispatch_semaphore_signal( executeSemphore )
                            }
                            
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
}
