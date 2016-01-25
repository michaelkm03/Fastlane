//
//  MainRequestExecutor.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import VictoriousCommon

class MainRequestExecutor: RequestExecutorType {
    
    private let networkActivityIndicator = NetworkActivityIndicator.sharedInstance()
    private let alertsReceiver = AlertReceiverSelector.defaultReceiver
    private(set) var error: NSError?
    
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?) {
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(environment: currentEnvironment)
        let baseURL = currentEnvironment.baseURL
        let authenticationContext: AuthenticationContext? = dispatch_sync( dispatch_get_main_queue() ) {
            return AuthenticationContext(currentUser: VCurrentUser.user())
        }
        
        networkActivityIndicator.start()
        let executeSemphore = dispatch_semaphore_create(0)
        
        let requestWithAlertsParsing = AlertsRequestDecorator(request: request)
        requestWithAlertsParsing.execute(
            baseURL: baseURL,
            requestContext: requestContext,
            authenticationContext: authenticationContext,
            callback: { (result, error) in
                dispatch_async( dispatch_get_main_queue() ) {
                    
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
                        
                    } else if let result = result {
                        if !result.alerts.isEmpty {
                            self.alertsReceiver.onAlertsReceived( result.alerts )
                        }
                        if let onComplete = onComplete {
                            onComplete( result.result ) {
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