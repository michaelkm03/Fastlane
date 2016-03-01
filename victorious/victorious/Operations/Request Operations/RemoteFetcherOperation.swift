//
//  RemoteFetcherOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import VictoriousCommon

class RemoteFetcherOperation: FetcherOperation {
    
    lazy var requestExecutor: RequestExecutorType = MainRequestExecutor()
    
    /// An array of `RequestErrorHandler` objects that will handle errors when requests are executed.
    /// Calling code may append, filter or anything else to customize the behavior.  When an error occurs,
    /// `MainRequestExecutor` iterates through error handlers until it finds one that can
    /// handle the error, then returns so that each error is handler by only one handler.
    var errorHandlers = [RequestErrorHandler]()
    
    override func cancel() {
        super.cancel()
        
        dispatch_async( dispatch_get_main_queue() ) {
            self.requestExecutor.cancelled = true
        }
    }
    
    private let networkActivityIndicator = NetworkActivityIndicator.sharedInstance()
    private let alertsReceiver = AlertReceiverSelector.defaultReceiver
    
    override var error: NSError? {
        set {
            super.error = newValue
        }
        get {
            return requestExecutor.error ?? super.error
        }
    }
    
    /// Allows subclasses to override to disabled unauthorized (401) error handling.
    /// Otherwise, these errors are handled by default.
    var requiresAuthorization: Bool = true {
        didSet {
            if requiresAuthorization {
                if !errorHandlers.contains({ $0 is UnauthorizedErrorHandler }) {
                    errorHandlers.append( UnauthorizedErrorHandler() )
                }
            } else {
                errorHandlers = errorHandlers.filter { ($0 is UnauthorizedErrorHandler) == false }
            }
        }
    }
}
