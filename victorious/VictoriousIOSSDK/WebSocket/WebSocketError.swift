//
//  WebSocketError.swift
//  victorious
//
//  Created by Sebastian Nystorm on 15/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

//
// The differents error cases originating from the WebSocket.
//
// - URLInvalid: An invalid URL is used for connecting.
// - AuthenticationTokenNotValid: The WebSocket authentication token used is not valid.
// - ConnectionTerminated: Connection closed, could contain a code and an error.
//
public enum WebSocketError: ErrorType, Equatable, CustomStringConvertible {
    case URLInvalid
    case AuthenticationTokenNotValid
    case ConnectionTerminated(code: Int?, error: NSError?)

    public var description: String {
        switch self {
        case .URLInvalid:
            return "URL invalid."
        case .AuthenticationTokenNotValid:
            return "Authentication token not valid."
        case .ConnectionTerminated(let code, let error):
            return "Connection terminated. Code: \(code) Error: \(error)"
        }
    }
}

public func ==(lhs: WebSocketError, rhs: WebSocketError) -> Bool {
    switch (lhs, rhs) {
    case (.URLInvalid, .URLInvalid):
        return true
    case (.AuthenticationTokenNotValid, .AuthenticationTokenNotValid):
        return true
    case (let .ConnectionTerminated(code1, error1), let .ConnectionTerminated(code2, error2)):
        return (code1 == code2) || (error1 == error2)
    default:
        return false
    }
}
