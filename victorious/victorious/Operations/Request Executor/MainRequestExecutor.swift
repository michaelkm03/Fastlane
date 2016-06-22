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
    
    /// An error stored from the last request that was executed.  It is always populated
    /// regardless of whether or not an `RequestErrorHandler` handled it.
    private(set) var error: NSError?
    
    /// An array of `RequestErrorHandler` objects that will handle errors when requests are executed.
    /// Calling code may append, filter or anything else to customize the behavior.  When an error occurs,
    /// `MainRequestExecutor` iterates through error handlers until it finds one that can
    /// handle the error, then returns so that each error is handler by only one handler.
    var errorHandlers = [RequestErrorHandler]()
    
    private func handleError(error: NSError) -> NSError? {
        for handler in errorHandlers {
            if handler.handleError(error) {
                return nil
            }
        }
        return error
    }
    
    private let networkActivityIndicator = NetworkActivityIndicator.sharedInstance()
    private let alertsReceiver = AlertReceiverSelector.defaultReceiver
    
    var cancelled: Bool = false
    
    func executeRequest<T: RequestType>(request: T, onComplete: (T.ResultType -> ())?, onError: (NSError -> ())?) {
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(environment: currentEnvironment)
        let baseURL = request.baseURL ?? currentEnvironment.baseURL
        
        let authenticationContext: AuthenticationContext? = dispatch_sync(dispatch_get_main_queue()) {
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
                dispatch_async(dispatch_get_main_queue()) {
                    defer {
                        dispatch_semaphore_signal(executeSemphore)
                    }

                    guard !self.cancelled else {
                        return
                    }

                    if let error = error as? RequestErrorType {
                        let nsError = NSError(error)
                        self.error = nsError
                        self.handleError(nsError)
                        onError?(nsError)
                    } else if let result = result {
                        if !result.alerts.isEmpty {
                            self.alertsReceiver.onAlertsReceived( result.alerts )
                        }
                        onComplete?(result.result)
                    }
                }
            }
        )
        dispatch_semaphore_wait(executeSemphore, DISPATCH_TIME_FOREVER)
        networkActivityIndicator.stop()
    }
}
