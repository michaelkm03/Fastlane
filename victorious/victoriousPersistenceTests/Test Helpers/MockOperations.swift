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
    let priority: Int
    
    init(code: Int, priority: Int) {
        self.code = code
        self.priority = priority
    }
    
    private(set) var errorsHandled = [NSError]()
    
    func handleError(error: NSError) -> Bool {
        if error.code == code {
            errorsHandled.append(error)
            return true
        }
        return false
    }
}

class MockRequestOperation: RequestOperation {
    var validRequest: MockRequest
    init(request: MockRequest) {
        validRequest = request
    }
    
    override func main() {
        requestExecutor.executeRequest( validRequest, onComplete: nil, onError: nil )
    }
}

class MockErrorRequestOperation: RequestOperation {
    var errorRequest: MockErrorRequest
    init(request: MockErrorRequest) {
        errorRequest = request
    }
    
    override func main() {
        requestExecutor.executeRequest( errorRequest, onComplete: nil, onError: nil )
    }
}
