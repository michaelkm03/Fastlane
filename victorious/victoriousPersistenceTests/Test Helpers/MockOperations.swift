//
//  MockOperations.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
@testable import victorious

class MockErrorHandler: NSObject, RequestErrorHandler {
    
    let code: Int
    
    init(code: Int) {
        self.code = code
    }
    
    private(set) var errorsHandled = [NSError]()
    
    func handle(error: NSError, with request: NSURLRequest? = nil) -> Bool {
        if error.code == code {
            errorsHandled.append(error)
            return true
        }
        return false
    }
}

class MockFetcherOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: MockRequest! = MockRequest()
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: onError)
    }
    
    private func onComplete(sequence: MockRequest.ResultType) {
        self.results = [NSObject(), NSObject()]
    }
    
    private func onError(error: NSError) {
        self.error = error
    }
}
