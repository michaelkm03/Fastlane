//
//  MockOperations.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
@testable import victorious

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
