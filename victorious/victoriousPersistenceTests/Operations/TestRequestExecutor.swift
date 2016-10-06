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

    let result: Any?

    var executeRequestCallCount = 0
    
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
    
    // MARK: - RequestExecutorType
    
    let error: NSError?
    
    var errorHandlers = [RequestErrorHandler]()
    
    var cancelled: Bool = false
    
    func executeRequest<T: RequestType>(_ request: T, onComplete: ((T.ResultType) -> ())?, onError: ((NSError)->())?) {
        executeRequestCallCount += 1
        
        if cancelled {
            return
        }
        
        if let error = self.error {
            onError?( error )
            
        } else if let result = (Void() as? T.ResultType) ?? (self.result as? T.ResultType) {
            onComplete?( result )
    
        } else {
            XCTFail("Unable to provide properly typed parameter to `onComplete` closure.")
        }
    }
}
