//
//  TestRequestExecutor.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@testable import victorious
@testable import VictoriousIOSSDK

class TestRequestExecutor: RequestExecutable {
    var executeRequestCallCount = 0

    func executeRequest<T : RequestType>(request: T, onComplete: ((T.ResultType, () -> ()) -> ())?, onError: ((NSError, () -> ()) -> ())?, hasNetworkConnection: Bool) {
        executeRequestCallCount += 1
    }
}
