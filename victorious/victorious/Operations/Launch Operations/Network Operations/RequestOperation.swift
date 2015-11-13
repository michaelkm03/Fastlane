//
//  RequestOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class RequestOperation<T: RequestType> : Operation {
    
    private var request: T
    
    private var error: NSError?
    
    init( request: T ) {
        self.request = request
    }
    
    func onResponse( result: T.ResultType ) {
        // Override in subclasses
    }
    
    override func cancel() {
        super.cancel()
        
        if let request = self.request as? Cancelable {
            request.cancel()
        }
    }
    
    func queue( completioneBlock:((NSError?)->())?) {
        self.completionBlock = {
            self.onComplete()
            completioneBlock?( self.error )
        }
        NSOperationQueue.mainQueue().addOperation( self )
    }
    
    func onComplete() {
        // Override in subclasses
    }
    
    func onError( error: NSError? ) {
        // Override in subclasses
    }
    
    override func start() {
        super.start()
        
        guard !cancelled else {
            finishedExecuting()
            return
        }
        beganExecuting()
        
        var authenticationContext: AuthenticationContext?
        if let currentUser = VUser.currentUser(inContext: PersistentStore.backgroundContext) {
            authenticationContext = AuthenticationContext(v_currentUser: currentUser)
        }
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(v_environment: currentEnvironment)
        let baseURL = currentEnvironment.baseURL
        
        request.execute(
            baseURL: baseURL,
            requestContext: requestContext,
            authenticationContext: authenticationContext,
            callback: { (result, error) -> () in
                guard !self.cancelled else {
                    return
                }
                if let result = result {
                    self.onResponse( result )
                } else {
                    self.onError( error as? NSError )
                }
                self.finishedExecuting()
            }
        )
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
