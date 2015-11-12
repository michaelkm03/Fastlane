//
//  NetworkOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

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


private let networkOperationQueue = NSOperationQueue()

class NetworkOperation<T: RequestType> : Operation {
    
    private var request: T
    
    init( request: T ) {
        self.request = request
    }
    
    private var error: ErrorType?
    
    func queueInBackground( completionMainQueueBlock:((ErrorType?)->())? = nil ) {
        self.completionBlock = {
            dispatch_async( dispatch_get_main_queue()) {
                completionMainQueueBlock?( self.error )
            }
        }
        networkOperationQueue.addOperation( self )
    }
    
    func onResponse( result: T.ResultType ) {}
    
    func onError( error: ErrorType? ) {}
    
    override func start() {
        super.start()
        
        guard !cancelled else {
            finishedExecuting()
            return
        }
        
        guard let currentUser = VUser.currentUser(inContext: PersistentStore.backgroundContext) else {
            finishedExecuting()
            return
        }
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let authenticationContext =  AuthenticationContext(v_currentUser: currentUser)
        let requestContext = RequestContext(v_environment: currentEnvironment)
        let baseURL = currentEnvironment.baseURL
        
        request.execute(
            baseURL: baseURL,
            requestContext: requestContext,
            authenticationContext: authenticationContext,
            callback: { [weak self] (result, error) -> () in
                guard let strongSelf = self else {
                    return
                }
                guard !strongSelf.cancelled else {
                    strongSelf.finishedExecuting()
                    return
                }
                
                if let result = result {
                    strongSelf.onResponse( result )
                } else {
                    strongSelf.onError( error )
                }
                strongSelf.finishedExecuting()
            }
        )
    }
}