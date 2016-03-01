//
//  TestRequestExecutor.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class TestRequestExecutor: RequestExecutorType {

    let error: NSError?
    let result: Any?
    
    var errorHandlers = [RequestErrorHandler]()

    var executeRequestCallCount = 0
    var hasNetworkConnection: Bool = true
    
    init(error: NSError) {
        self.error = error
        self.result = nil
    }
    
    init(result: Any) {
        self.error = nil
        self.result = result
    }
    
    init() {
        self.error = nil
        self.result = nil
    }
    
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?) {
        executeRequestCallCount += 1
        
        let executeSemphore = dispatch_semaphore_create(0)
        if let error = self.error {
            if let onError = onError {
                onError( error ) {
                    dispatch_semaphore_signal( executeSemphore )
                }
            } else {
                dispatch_semaphore_signal( executeSemphore )
            }
            
        } else if let result = Void() as? T.ResultType ?? self.result as? T.ResultType {
            if let onComplete = onComplete {
                onComplete( result ) {
                    dispatch_semaphore_signal( executeSemphore )
                }
            } else {
                dispatch_semaphore_signal( executeSemphore )
            }
        } else {
            XCTFail("Unable to provide properly typed parameter to `onComplete` closure.")
        }
        dispatch_semaphore_wait( executeSemphore, DISPATCH_TIME_FOREVER )
    }
}
