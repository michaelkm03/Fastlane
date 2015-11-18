//
//  RequestOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

private let _defaultQueue = NSOperationQueue()

class RequestOperation<T: RequestType> : NSOperation {
    
    private(set) var requestError: NSError?
    
    let request: T
    
    var mainQueueCompletionBlock: ((NSError?)->())?
    
    var defaultQueue: NSOperationQueue {
        return _defaultQueue
    }
    
    init( request: T ) {
        self.request = request
    }
    
    final func queue( completionBlock:((NSError?)->())? = nil) {
        if let completionBlock = completionBlock {
            self.mainQueueCompletionBlock = completionBlock
        }
        self.completionBlock = {
            dispatch_async( dispatch_get_main_queue() ) { [weak self] in
                guard let strongSelf = self where !strongSelf.cancelled else {
                    return
                }
                let error: NSError? = nil // FIXME
                strongSelf.onComplete( error )
                strongSelf.mainQueueCompletionBlock?( error )
            }
        }
        _defaultQueue.addOperation( self )
    }
    
    func cancelAllOperations() {
        for operation in _defaultQueue.operations {
            operation.cancel()
        }
    }
    
    // MARK: - Subclassing
    
    /// Called on background thread, designed to be overriden in subclasses.
    func onStart() {}
    
    /// Called on background thread, designed to be overriden in subclasses.
    func onResponse( response: T.ResultType ) {}
    
    /// Called on main thread, designed to be overriden in subclasses.
    func onComplete( error: NSError? ) {}
    
    func onError( error: NSError? ) {}
    
    // MARK: - NSOperation overrides
    
    final override func cancel() {
        super.cancel()
        
        if let request = self.request as? Cancelable {
            request.cancel()
        }
    }
    
    final override func main() {
        let semaphore = dispatch_semaphore_create(0)
        self.onStart()
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(v_environment: currentEnvironment)
        let baseURL = currentEnvironment.baseURL
        let authenticationContext: AuthenticationContext? = {
            if let identifier = VUser.currentUser()?.identifier,
                let currentUser: VUser = PersistentStore.backgroundContext.getObject( identifier ) {
                    return AuthenticationContext(v_currentUser: currentUser)
            }
            return nil
        }()
        
        self.request.execute(
            baseURL: baseURL,
            requestContext: requestContext,
            authenticationContext: authenticationContext,
            callback: { [weak self] (result, error) -> () in
                guard let strongSelf = self where !strongSelf.cancelled else {
                    return
                }
                if let theResult = result {
                    strongSelf.onResponse( theResult )
                } else {
                    //strongSelf.requestError = (error as? NSError)?.copy() as? NSError
                    strongSelf.onError( nil )
                }
                dispatch_async( dispatch_get_main_queue() ) {
                    dispatch_semaphore_signal( semaphore )
                }
            }
        )
        dispatch_semaphore_wait( semaphore, DISPATCH_TIME_FOREVER )
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
