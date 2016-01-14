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
    
    var error: NSError? { get }
    
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?)
}
