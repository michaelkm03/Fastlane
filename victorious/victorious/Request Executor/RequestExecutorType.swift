//
//  RequestExecutorType.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK

/// Defines an object that executes concrete implementations of `RequestType`
protocol RequestExecutorType: class {
    
    /// Objects must be able to provide any errors encountered during executing.
    /// This value, if defined, should reference the same `NSError` instance returned in the `onError:` closure
    /// provided to `requestExecutor.executeRequest(_:onComplete:onError:)`
    var error: NSError? { get }
    
    var cancelled: Bool { set get }
    
    var errorHandlers: [RequestErrorHandler] { get set }
    
    /// Executes the provided request and calls the `onComplete` or `onError` block when
    /// when the request finishes successfully executing or fails, respectively.  These closures
    /// are optional in cases where calling node isn't concerned with the response of the request,
    /// i.e. "fire and forget".
    func executeRequest<T: RequestType>(_ request: T, onComplete: ((T.ResultType) -> ())?, onError: ((NSError)->())?)
}
