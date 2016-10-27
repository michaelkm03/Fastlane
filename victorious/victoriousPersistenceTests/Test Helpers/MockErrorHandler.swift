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
    
    func handle(_ error: NSError, with request: URLRequest? = nil) -> Bool {
        if error.code == code {
            errorsHandled.append(error)
            return true
        }
        return false
    }
}
