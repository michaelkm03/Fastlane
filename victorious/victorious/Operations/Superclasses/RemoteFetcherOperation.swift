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

/// An operation whose primary function is to use a VictoriousiOSSDK.RequestType
/// to execute a network request and parse and insert results into a background
/// context of the persistent store.
class RemoteFetcherOperation: FetcherOperation {
    
    lazy var requestExecutor: RequestExecutorType = MainRequestExecutor()
    
    private let networkActivityIndicator = NetworkActivityIndicator.sharedInstance()
    private let alertsReceiver = AlertReceiverSelector.defaultReceiver
    
    override init() {
        super.init()
        addDefaultErrorHandlers()
    }
    
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
                self.addDefaultErrorHandlers()
            } else {
                requestExecutor.errorHandlers = requestExecutor.errorHandlers.filter { ($0 is UnauthorizedErrorHandler) == false }
            }
        }
    }
    
    override func cancel() {
        super.cancel()
        
        dispatch_async( dispatch_get_main_queue() ) {
            self.requestExecutor.cancelled = true
        }
    }
    
    private func addDefaultErrorHandlers() {
        if !requestExecutor.errorHandlers.contains({ $0 is UnauthorizedErrorHandler }) {
            requestExecutor.errorHandlers.append( UnauthorizedErrorHandler() )
        }
        if !requestExecutor.errorHandlers.contains({ $0 is DebugErrorHandler }) {
            requestExecutor.errorHandlers.append( DebugErrorHandler(requestIdentifier: "\(self.dynamicType)") )
        }
    }
}
