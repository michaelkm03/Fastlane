//
//  TestRequestExecutor.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@testable import victorious
@testable import VictoriousIOSSDK

class TestRequestExecutor<T: RequestType>: RequestExecutorType {
    var executeRequestCallCount = 0
    var hasNetworkConnection: Bool = true
    var onCompleteResult: T.ResultType?
    
    func executeRequest<T: RequestType>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?) {
        executeRequestCallCount += 1
        if let onCompleteResult = onCompleteResult, let onComplete = onComplete {
            //            let emptyClosure = {}
            //            let onCompleteCall = { (onCompleteResult, emptyClosure) }
            onComplete(onCompleteResult) {
                print("HERE!")
            }
        }
    }
}