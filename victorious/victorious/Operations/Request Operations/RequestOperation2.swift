//
//  RequestOperation2.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import VictoriousCommon

class RequestOperation: Operation {
    
    let persistentStore: PersistentStoreType = MainPersistentStore()
    
    var error: NSError?
    
    final func executeRequest<T: RequestType>(request: T, completion: (T.ResultType?, NSError?)->() ) {
        
        var baseURL: NSURL?
        var requestContext: RequestContext?
        var authenticationContext: AuthenticationContext?
        
        let startSemaphore = dispatch_semaphore_create(0)
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
        }
        dispatch_semaphore_wait( startSemaphore, DISPATCH_TIME_FOREVER )
        
        request.execute(
            baseURL: baseURL!,
            requestContext: requestContext!,
            authenticationContext: authenticationContext,
            callback: { (result, error) -> () in
                dispatch_async( dispatch_get_main_queue() ) {
                    if let error = error as? RequestErrorType {
                        let nsError = NSError( error )
                        completion( nil, nsError )
                    }
                    else if let requestResult = result {
                        completion( requestResult, nil )
                    }
                }
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
