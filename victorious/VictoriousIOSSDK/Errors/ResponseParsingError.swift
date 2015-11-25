//
//  ResponseParsingError.swift
//  victorious
//
//  Created by Patrick Lynch on 11/25/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// ErrorType thrown when an endpoint request succeeds on an TCP/IP and HTTP level, but for some reason the response couldn't be parsed.
public struct ResponseParsingError: RequestErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    
    public let localizedDescription: String
    
    public var description: String {
        return localizedDescription
    }
    
    public var debugDescription: String {
        return description
    }
    
    public init(localizedDescription: String? = nil ) {
        self.localizedDescription = localizedDescription ?? ResponseParsingError.errorTypeDomain
    }
    
    public static let errorTypeDomain = kVRequestTypeResponseParsingErrorDomain
}
