//
//  APIError.swift
//  victorious
//
//  Created by Patrick Lynch on 11/25/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// ErrorType thrown when the Victorious API returns a parsable error response that contains detailed information about the error
public struct APIError: RequestErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    
    public let localizedDescription: String
    public let code: Int
    
    public var description: String {
        return localizedDescription
    }
    
    public var debugDescription: String {
        return description
    }
    
    public init(localizedDescription: String? = nil, code: Int? = nil) {
        self.localizedDescription = localizedDescription ?? APIError.errorTypeDomain
        self.code = code ?? -1
    }
    
    public static let errorTypeDomain = kVRequestTypeAPIErrorDomain
}
