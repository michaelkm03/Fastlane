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
    
    private let networkActivityIndicator = NetworkActivityIndicator.sharedInstance()
    private(set) var error: NSError?

    
    weak var delegate: RequestExecutorDelegate? = nil
    
    private var hasNetworkConnection: Bool {
        return VReachability.reachabilityForInternetConnection().currentReachabilityStatus() != .NotReachable
    }
    
    let baseURL: NSURL
    let requestContext: RequestContext
    let authenticationContext: AuthenticationContext?
    
    init(baseURL: NSURL, requestContext: RequestContext, authenticationContext: AuthenticationContext? ) {
        self.baseURL = baseURL
        self.requestContext = requestContext
        self.authenticationContext = authenticationContext
    }
    
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?) {
        
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
                            self.delegate?.didReceiveAlerts( alerts )
                        }
                        
                        if let error = error as? RequestErrorType {
                            let nsError = NSError( error )
                            self.error = nsError
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
