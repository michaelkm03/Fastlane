//
//  WebSocketError.swift
//  victorious
//
//  Created by Sebastian Nystorm on 15/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

//
// The differents error cases originating from the WebSocket. Could either be custom ones from our backend or
/// be the ones baked into the protocol generated by the OS.
//
// - missingAppId: Nonexisting app id sent.
// - missingToken: Token did not exist in URL for opening the WebSocket connection.
// - unsupportedApp: Current app has no support for WebSockets.
// - unrecognizedToken: Token not recognized.
// - unsupportedProtocol: Protocol sent is not valid, this does NOT refer to the actual WebSocket protocol but the part we use to transfer data.
// - connectionTerminated: Connection closed, could contain a code and an error.
//
public enum WebSocketError: ErrorType, Equatable, CustomStringConvertible {
    case missingAppId(message: String)
    case missingToken(message: String)
    case unsupportedApp(message: String)
    case unrecognizedToken(message: String)
    case unsupportedProtocol(message: String)
    case connectionTerminated(code: Int?, message: String?)

    public var description: String {
        var description: String

        switch self {
            case .missingAppId(let message):
                description = message
            case .missingToken(let message):
                description = message
            case .unsupportedApp(let message):
                description = message
            case .unrecognizedToken(let message):
                description = message
            case .unsupportedProtocol(let message):
                description = message
            case .connectionTerminated(let code, let error):
                return "Connection terminated. Code: \(code) Error: \(error)"
        }

        return description
    }

    /// Creates a WebSocketError from JSON, the `didDisconnect` flag is used to distinguish between error messages originating
    /// from a closed connection. The flag is needed so we can distinguish from error messages terminating the connection.
    public init?(json: JSON, didDisconnect: Bool) {
        guard
            let message = json["message"].string,
            let code = json["code"].int
        else {
                return nil
        }

        if didDisconnect {
            self = .connectionTerminated(code: code, message: message)
        } else {
            // Error codes are not important to us on a system level since we translate them into our enum.
            switch code {
                case 10:
                    self = .missingAppId(message: message)
                case 20:
                    self = .missingToken(message: message)
                case 30:
                    self = .unsupportedApp(message: message)
                case 40:
                    self = .unrecognizedToken(message: message)
                case 50:
                    self = .unsupportedProtocol(message: message)
                default:
                    return nil
            }
        }
    }
}

public func ==(lhs: WebSocketError, rhs: WebSocketError) -> Bool {
    switch (lhs, rhs) {
        case (let .missingAppId(message1), let .missingAppId(message2)):
            return (message1 == message2)
        case (let .missingToken(message1), let .missingToken(message2)):
            return (message1 == message2)
        case (let .unsupportedApp(message1), let .unsupportedApp(message2)):
            return (message1 == message2)
        case (let .unrecognizedToken(message1), let .unrecognizedToken(message2)):
            return (message1 == message2)
        case (let .unsupportedProtocol(message1), let .unsupportedProtocol(message2)):
            return (message1 == message2)
        case (let .connectionTerminated(code1, message1), let .connectionTerminated(code2, message2)):
            return (code1 == code2) || (message1 == message2)
        default:
            return false
    }
}
