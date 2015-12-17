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

private let _defaultQueue = NSOperationQueue()

class RequestOperation: NSOperation, Queuable {
    
    static let errorDomain: String = "com.getvictorious.RequestOperation"
    static let errorCodeNoNetworkConnection: Int = 9001
    
    var defaultQueue: NSOperationQueue { return _defaultQueue }
    
    static var sharedQueue: NSOperationQueue { return _defaultQueue }
    
    var mainQueueCompletionBlock: ((NSError?)->())?
    
    let persistentStore: PersistentStoreType = MainPersistentStore()
    let networkActivityIndicator = NetworkActivityIndicator.sharedInstance()
    
    private(set) var error: NSError?
    
    final func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())? = nil, onError: ((NSError, ()->())->())? = nil ) {

        assert( NSThread.currentThread().isMainThread == false )
        
        var baseURL: NSURL?
        var requestContext: RequestContext?
        var authenticationContext: AuthenticationContext?
        
        dispatch_sync( dispatch_get_main_queue() ) {
            
            let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
            requestContext = RequestContext(v_environment: currentEnvironment)
            baseURL = currentEnvironment.baseURL
            
            let currentUserObjectID = VUser.currentUser()?.objectID
            let persistentStore: PersistentStoreType = MainPersistentStore()
            authenticationContext = persistentStore.mainContext.v_performBlockAndWait() { context in
                if let currentUserObjectID = currentUserObjectID, let currentUser: VUser = context.v_objectWithID(currentUserObjectID) {
                    return AuthenticationContext(v_currentUser: currentUser)
                }
                return nil
            }
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
                baseURL: baseURL!,
                requestContext: requestContext!,
                authenticationContext: authenticationContext,
                callback: { (result, error) -> () in
                    dispatch_async( dispatch_get_main_queue() ) {
                        if let error = error as? RequestErrorType {
                            let nsError = NSError( error )
                            if let onError = onError {
                                onError( nsError ) {
                                    dispatch_semaphore_signal( executeSemphore )
                                }
                            } else {
                                print( "Error in operation: \(self.dynamicType):\n \(error)" )
                                dispatch_semaphore_signal( executeSemphore )
                            }
                        }
                        else if let requestResult = result {
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

private extension AuthenticationContext {
    init?( v_currentUser currentUser: VUser? ) {
        guard let currentUser = currentUser else {
            return nil
        }
        self.init( userID: Int64(currentUser.remoteId.integerValue), token: currentUser.token)
    }
}

private extension RequestContext {
    init( v_environment environment: VEnvironment ) {
        let deviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? ""
        let buildNumber: String
        
        if let buildNumberFromBundle = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String {
            buildNumber = buildNumberFromBundle
        } else {
            buildNumber = ""
        }
        self.init(appID: environment.appID.integerValue, deviceID: deviceID, buildNumber: buildNumber)
    }
}
