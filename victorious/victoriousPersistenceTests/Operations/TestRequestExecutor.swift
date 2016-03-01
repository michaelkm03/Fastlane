//
//  TestRequestExecutor.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@testable import victorious
@testable import VictoriousIOSSDK

protocol TestRequestExecutorDelegate {
    
    func stubOnComplete<T: RequestType>() -> T.ResultType
}

class TestRequestExecutor: RequestExecutorType {

    private(set) var error: NSError?
    
    init(delegate: TestRequestExecutorDelegate) {
        self.delegate = delegate
    }
    
    var delegate: TestRequestExecutorDelegate
    
    var errorHandlers = [RequestErrorHandler]()

    var executeRequestCallCount = 0
    var hasNetworkConnection: Bool = true
    
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?) {
        executeRequestCallCount += 1
        
        //TODO: Figure out how to call onComplete or onError here
    }
}