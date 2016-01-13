//
//  RequestExecutorType.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK

protocol RequestExecutorDelegate: class {
    func didReceiveAlerts( alerts: [Alert] )
}

/// Defines an interface for sending network requests
protocol RequestExecutorType {
    
    var delegate: RequestExecutorDelegate? { set get }
    
    /// Objects must be able to provide any errors encountered during executing.
    /// This value, if defined, should reference the same `NSError` instance returned in the `onError:` closure
    /// provided to `executeRequest(_:onComplete:onError:)`
    var error: NSError? { get }
    
    /// Executes the provided request and calls the `onComplete` or `onError` block when
    /// when the request finishes successfully executing or fails, respectively.  These closures
    /// are optional in cases where calling node isn't concerned with the response of the request,
    /// i.e. "fire and forget".

    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?)
}
