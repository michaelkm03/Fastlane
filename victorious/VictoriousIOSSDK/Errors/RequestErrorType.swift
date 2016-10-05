//
//  RequestErrorType.swift
//  victorious
//
//  Created by Patrick Lynch on 11/25/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public protocol RequestErrorType: Error {
    var code: Int { get }
    var localizedDescription: String { get }
    var domain: String { get }
    static var errorTypeDomain: String { get }
}

public extension RequestErrorType {
    public var code: Int {
        return -1
    }
    
    var domain: String {
        return Self.errorTypeDomain
    }
}

public extension NSError {
    public convenience init( _ requestError: RequestErrorType ) {
        self.init(
            domain: requestError.domain,
            code: requestError.code,
            userInfo: [
                NSLocalizedDescriptionKey: requestError.localizedDescription
            ]
        )
    }
}
