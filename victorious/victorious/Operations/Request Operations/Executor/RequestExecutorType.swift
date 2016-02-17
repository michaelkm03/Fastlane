//
//  RequestExecutorType.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK

/// Defines an object that can be asked to handle errors.
protocol RequestErrorHandler: class {
    
    /// Used to sort error handlers before asking one of a group of error handlers
    /// to handle an error.  Consumers of `RequestErrorHandler` are designed to
    /// call `handleError` for only the handler with the highest-ranking priority.
    var priority: Int { get }
    
    /// Asks the receiver to handle the error provided.
    /// - returns `true` if the error could be handed by the receiver, and `false` if it was not possible.
    func handleError( error: NSError ) -> Bool
}

/// Defines an object that executes concrete implementations of `RequestType`
protocol RequestExecutorType: class {
    
    /// Objects must be able to provide any errors encountered during executing.
    /// This value, if defined, should reference the same `NSError` instance returned in the `onError:` closure
    /// provided to `executeRequest(_:onComplete:onError:)`
    var error: NSError? { get }
    
    var errorHandlers: [RequestErrorHandler] { get set }
    
    /// Executes the provided request and calls the `onComplete` or `onError` block when
    /// when the request finishes successfully executing or fails, respectively.  These closures
    /// are optional in cases where calling node isn't concerned with the response of the request,
    /// i.e. "fire and forget".
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?)
}
