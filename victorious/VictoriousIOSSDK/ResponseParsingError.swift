//
//  RequestTypeErrors.swift
//  victorious
//
//  Created by Patrick Lynch on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public protocol RequestError: ErrorType {
    var code: Int { get }
    var localizedDescription: String { get }
}

public extension RequestError {
    public var code: Int {
        return -1
    }
}

public extension NSError {
    public convenience init( _ requestError: RequestError ) {
        self.init(
            domain: "VictoriousIOSSDK.RequestError",
            code: requestError.code,
            userInfo: [
                NSLocalizedDescriptionKey : requestError.localizedDescription
            ]
        )
    }
}

/// ErrorType thrown when an endpoint request succeeds on an TCP/IP and HTTP level, but for some reason the response couldn't be parsed.
public struct ResponseParsingError: RequestError, CustomStringConvertible, CustomDebugStringConvertible {
    
    public let localizedDescription: String
    
    public var description: String {
        return localizedDescription ?? "ResponseParsingError"
    }
    
    public var debugDescription: String {
        return description
    }
    
    public init(localizedDescription: String = "") {
        self.localizedDescription = localizedDescription
    }
}

/// ErrorType thrown when the Victorious API returns a parsable error response that contains detailed information about the error
public struct APIError: RequestError, CustomStringConvertible, CustomDebugStringConvertible {
    
    public let localizedDescription: String
    public let code: Int
    
    public var description: String {
        return localizedDescription ?? ""
    }
    
    public var debugDescription: String {
        return description
    }
    
    public init(localizedDescription: String = "", code: Int = 0) {
        self.localizedDescription = localizedDescription
        self.code = code
    }
}
