//
//  RequestTypeErrors.swift
//  victorious
//
//  Created by Patrick Lynch on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation





/// ErrorType thrown when an endpoint request succeeds on an TCP/IP and HTTP level, but for some reason the response couldn't be parsed.
public struct ResponseParsingError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    
    public let localizedDescription: String?
    
    public var description: String {
        return localizedDescription ?? "ResponseParsingError"
    }
    
    public var debugDescription: String {
        return description
    }
    
    public init(localizedDescription: String? = nil) {
        self.localizedDescription = localizedDescription
    }
}

/// ErrorType thrown when the Victorious API returns a parsable error response that contains detailed information about the error
public struct APIError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    
    public let localizedDescription: String?
    public let code: Int
    
    public var description: String {
        return localizedDescription ?? "APIError \(code)"
    }
    
    public var debugDescription: String {
        return description
    }
    
    public init(localizedDescription: String? = nil, code: Int = 0) {
        self.localizedDescription = localizedDescription
        self.code = code
    }
}
