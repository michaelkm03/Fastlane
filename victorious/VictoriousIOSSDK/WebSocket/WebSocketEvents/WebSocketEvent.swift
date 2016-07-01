//
//  WebSocketEvent.swift
//  victorious
//
//  Created by Sebastian Nystorm on 24/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

///
/// The Forum Event Chain is used to transport control messages regarding the state of the WebSocket connection.
///
/// - Authenticated: The authentication handshake has been performed.
/// - AuthenticationFailed: The authentication handshake has failed with an error message
/// - Connected: The WebSocket connection is open.
/// - Disconnected: The WebSocket connection is closed with potentially an error message.
public enum WebSocketEvent: Equatable {
    case Authenticated
    case AuthenticationFailed(webSocketError: WebSocketError)
    case Connected
    case Disconnected(webSocketError: WebSocketError?)
}

public func ==(lhs: WebSocketEvent, rhs: WebSocketEvent) -> Bool {
    switch (lhs, rhs) {
    case (.Authenticated, .Authenticated):
        return true
    case (let .AuthenticationFailed(error1), let .AuthenticationFailed(error2)):
        return error1 == error2
    case (.Connected, .Connected):
        return true
    case (let .Disconnected(error1), let .Disconnected(error2)):
        return error1 == error2
    default:
        return false
    }
}
