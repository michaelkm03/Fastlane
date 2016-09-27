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
    fileprivate(set) var error: NSError?
    
    /// An array of `RequestErrorHandler` objects that will handle errors when requests are executed.
    /// Calling code may append, filter or anything else to customize the behavior.  When an error occurs,
    /// `MainRequestExecutor` iterates through error handlers until it finds one that can
    /// handle the error, then returns so that each error is handler by only one handler.
    var errorHandlers = [RequestErrorHandler]()
    
    fileprivate func handle(_ error: NSError, with request: URLRequest? = nil) -> NSError? {
        for handler in errorHandlers {
            if handler.handle(error, with: request) {
                return nil
            }
        }
        return error
    }
    
    fileprivate let networkActivityIndicator = NetworkActivityIndicator.sharedInstance()
    fileprivate let alertsReceiver = AlertReceiverSelector.defaultReceiver
    
    var cancelled: Bool = false
    
    func executeRequest<T: RequestType>(_ request: T, onComplete: ((T.ResultType) -> ())?, onError: ((NSError) -> ())?) {
        
        let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
        let requestContext = RequestContext(environment: currentEnvironment)
        let baseURL = request.baseURL ?? currentEnvironment.baseURL
        
        let authenticationContext = AuthenticationContext()
        
        networkActivityIndicator.start()
        let executeSemphore = DispatchSemaphore(value: 0)
        
        let requestWithAlertsParsing = AlertsRequestDecorator(request: request)
        requestWithAlertsParsing.execute(
            baseURL: baseURL,
            requestContext: requestContext,
            authenticationContext: authenticationContext,
            callback: { (result, error) in
                DispatchQueue.main.async {
                    defer {
                        dispatch_semaphore_signal(executeSemphore)
                    }

                    guard !self.cancelled else {
                        return
                    }

                    if let nsError = self.convertError(error) {
                        self.error = nsError
                        self.handle(nsError, with: request.urlRequest)
                        onError?(nsError)
                    } else if let result = result {
                        if !result.alerts.isEmpty {
                            self.alertsReceiver.receive(result.alerts)
                        }
                        onComplete?(result.result)
                    }
                }
            }
        )
        executeSemphore.wait(timeout: DispatchTime.distantFuture)
        networkActivityIndicator.stop()
    }
    
    fileprivate func convertError(_ error: Error?) -> NSError? {
        guard let error = error else {
            return nil
        }
        if let requestError = error as? RequestErrorType {
            return NSError(requestError)
        }
        else {
            return error as NSError
        }
    }
}
