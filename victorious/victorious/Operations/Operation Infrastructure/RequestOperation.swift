//
//  RemoteOperations.swift
//  victorious
//
//  Created by Jarod Long on 9/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

/// A generic operation that can be used to asynchronously execute a request.
class RequestOperation<Request: RequestType>: AsyncOperation<Request.ResultType> {
    
    // MARK: - Initializing
    
    init(request: Request) {
        self.request = request
    }
    
    // MARK: - Executing
    
    /// The request's executor. Defaults to a `MainRequestExecutor`, but can be swapped out before the operation
    /// executes.
    var requestExecutor: RequestExecutorType = MainRequestExecutor()
    
    /// The request that will be executed.
    let request: Request
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Request.ResultType>) -> Void) {
        if !requestExecutor.errorHandlers.contains(where: { $0 is UnauthorizedErrorHandler }) {
            requestExecutor.errorHandlers.append(UnauthorizedErrorHandler())
        }
        
        if !requestExecutor.errorHandlers.contains(where: { $0 is DebugErrorHandler }) {
            requestExecutor.errorHandlers.append(DebugErrorHandler(requestIdentifier: "\(type(of: self))"))
        }
        
        requestExecutor.executeRequest(
            request,
            onComplete: { result in
                finish(.success(result))
            },
            onError: { error in
                finish(.failure(error))
            }
        )
    }
}
