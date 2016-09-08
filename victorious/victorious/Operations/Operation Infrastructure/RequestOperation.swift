//
//  RemoteOperations.swift
//  victorious
//
//  Created by Jarod Long on 9/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A generic operation that can be used to asynchronously execute a request.
class RequestOperation<Request: RequestType>: AsyncOperation<Request.ResultType> {
    
    // MARK: - Initializing
    
    init(request: Request) {
        self.request = request
    }
    
    // MARK: - Executing
    
    private let request: Request
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(finish: (result: OperationResult<Request.ResultType>) -> Void) {
        let executor = MainRequestExecutor()
        
        if !executor.errorHandlers.contains({ $0 is UnauthorizedErrorHandler }) {
            executor.errorHandlers.append(UnauthorizedErrorHandler())
        }
        
        if !executor.errorHandlers.contains({ $0 is DebugErrorHandler }) {
            executor.errorHandlers.append(DebugErrorHandler(requestIdentifier: "\(self.dynamicType)"))
        }
        
        executor.executeRequest(
            request,
            onComplete: { result in
                finish(result: .success(result))
            },
            onError: { error in
                finish(result: .failure(error))
            }
        )
    }
}
