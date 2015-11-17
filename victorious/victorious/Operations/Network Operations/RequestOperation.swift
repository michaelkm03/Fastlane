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
    
    var defaultQueue: NSOperationQueue {
        return _defaultQueue
    }
    
    var currentEnvironment: VEnvironment {
        return VEnvironmentManager.sharedInstance().currentEnvironment
    }
    
    var requestContext: RequestContext {
        return RequestContext(v_environment: currentEnvironment)
    }
    
    var baseURL: NSURL {
        return currentEnvironment.baseURL
    }
    
    var authenticationContext: AuthenticationContext? {
        if let currentUser = VUser.currentUser(inContext: PersistentStore.backgroundContext) {
            return AuthenticationContext(v_currentUser: currentUser)
        }
        return nil
    }
    
    init( request: T ) {
        self.request = request
    }
    
    final func queue( completionBlock:((NSError?)->())? = nil) {
        self.completionBlock = {
            dispatch_async( dispatch_get_main_queue() ) { [weak self] in
                guard let strongSelf = self where !strongSelf.cancelled else {
                    return
                }
                let error = nil // NSError(domain: "We fucked", code: 0, userInfo: nil)
                strongSelf.onComplete( error )
                completionBlock?( error )
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
    func onResponse( response: T.ResultType ) {}
    
    /// Called on main thread, designed to be overriden in subclasses.
    func onComplete( error: NSError? ) {}
    
    // MARK: - NSOperation overrides
    
    final override func cancel() {
        super.cancel()
        
        if let request = self.request as? Cancelable {
            request.cancel()
        }
    }
    
    final override func main() {
        let semaphore = dispatch_semaphore_create(0)
        
        self.request.execute(
            baseURL: self.baseURL,
            requestContext: self.requestContext,
            authenticationContext: self.authenticationContext,
            callback: { [weak self] (result, error) -> () in
                guard let strongSelf = self where !strongSelf.cancelled else {
                    return
                }
                if let result = result {
                    strongSelf.onResponse( result )
                }
                //strongSelf.requestError = (error as? NSError)?.copy() as? NSError
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
