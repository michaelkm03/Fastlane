//
//  TestRequestExecutor.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@testable import victorious
@testable import VictoriousIOSSDK

class TestRequestExecutor: RequestExecutorType {

    private(set) var error: NSError?

    var executeRequestCallCount = 0
    var hasNetworkConnection: Bool = true
    
    var delegate: RequestExecutorDelegate?
    
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?) {
        executeRequestCallCount += 1
        
        /*if let onCompleteResult = onCompleteResult, let onComplete = onComplete {
            let emptyClosure = {}
            let onCompleteCall = { (onCompleteResult, emptyClosure) }
            onComplete(onCompleteResult) {
                print("HERE!")
            }
        }*/
    }
}