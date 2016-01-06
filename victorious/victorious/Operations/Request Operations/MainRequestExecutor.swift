//
//  MainRequestExecutor.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class MainRequestExecutor: RequestExecutorType {
    
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
                callback: { (result, error) -> () in
                    dispatch_async( dispatch_get_main_queue() ) {

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

private extension RequestContext {
    init( environment: VEnvironment ) {
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

private extension AuthenticationContext {
    init?( currentUser: VUser? ) {
        guard let currentUser = currentUser else {
            return nil
        }
        self.init( userID: currentUser.remoteId.integerValue, token: currentUser.token)
    }
}
