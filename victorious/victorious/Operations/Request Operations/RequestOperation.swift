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

class RequestOperation<T: RequestType> : NSOperation, Queuable {
    
    static var sharedQueue: NSOperationQueue { return _defaultQueue }
    
    var mainQueueCompletionBlock: ((NSError?)->())?
    
    private let request: T
    private(set) var requestError: NSError?
    
    var defaultQueue: NSOperationQueue {
        return _defaultQueue
    }
    
    init( request: T ) {
        self.request = request
    }
    
    // MARK: - Lifecycle Subclassing
    
    func onStart( completion:()->() ) {
        completion()
    }
    
    func onComplete( result: T.ResultType, completion:()->() ) {
        completion()
    }
    
    func onError( error: NSError, completion: ()->() ) {
        completion()
    }
    
    // MARK: - NSOperation overrides
    
    final override func cancel() {
        super.cancel()
        
        if let request = self.request as? Cancelable {
            request.cancel()
        }
    }
    
    final override func main() {
        let mainSemaphore = dispatch_semaphore_create(0)
        let startSemaphore = dispatch_semaphore_create(0)
        
        var baseURL: NSURL?
        var requestContext: RequestContext?
        var authenticationContext: AuthenticationContext?
        
        dispatch_async( dispatch_get_main_queue() ) {
            
            let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
            requestContext = RequestContext(v_environment: currentEnvironment)
            baseURL = currentEnvironment.baseURL
            
            let currentUserID = VUser.currentUser()?.identifier
            let persistentStore: PersistentStoreType = MainPersistentStore()
            authenticationContext = persistentStore.sync() { context in
                if let identifier = currentUserID, let currentUser: VUser = context.getObject(identifier) {
                    return AuthenticationContext(v_currentUser: currentUser)
                }
                return nil
            }
            self.onStart() {
                dispatch_semaphore_signal( startSemaphore )
            }
        }
        dispatch_semaphore_wait( startSemaphore, DISPATCH_TIME_FOREVER )
        
        self.request.execute(
            baseURL: baseURL!,
            requestContext: requestContext!,
            authenticationContext: authenticationContext,
            callback: { [weak self] (result, requestError) -> () in
                dispatch_async( dispatch_get_main_queue() ) {
                    guard let strongSelf = self where !strongSelf.cancelled else {
                        return
                    }
                    
                    if let requestError = requestError as? RequestErrorType {
                        let nsError = NSError( requestError )
                        strongSelf.requestError = nsError
                        strongSelf.onError( nsError ) {
                            dispatch_semaphore_signal( mainSemaphore )
                        }
                    }
                    else if let requestResult = result {
                        strongSelf.onComplete( requestResult ) {
                            dispatch_semaphore_signal( mainSemaphore )
                        }
                    }
                }
            }
        )
        dispatch_semaphore_wait( mainSemaphore, DISPATCH_TIME_FOREVER )
    }
    
    func queueOn( queue: NSOperationQueue, completionBlock:((NSError?)->())? = nil) {
        if let completionBlock = completionBlock {
            self.mainQueueCompletionBlock = completionBlock
        }
        self.completionBlock = {
            dispatch_async( dispatch_get_main_queue() ) { [weak self] in
                guard let strongSelf = self where !strongSelf.cancelled else {
                    return
                }
                strongSelf.mainQueueCompletionBlock?( strongSelf.requestError )
            }
        }
        _defaultQueue.addOperation( self )
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
