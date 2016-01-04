//
//  RequestExecutorType.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK

/// Defines an interface for sending network requests
protocol RequestExecutorType {
    
    /// Executes the provided request and calls the `onComplete` or `onError` block when
    /// when the request finishes successfully executing or fails.
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?)
}
