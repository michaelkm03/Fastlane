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
/// - authenticated: The authentication handshake has been performed.
/// - connected: The WebSocket connection is open.
/// - disconnected: The WebSocket connection is closed with an error message.
/// - serverError: A custom error message was sent from the backend.
public enum WebSocketEvent: Equatable {
    case authenticated
    case connected
    case disconnected(webSocketError: WebSocketError)
    case serverError(webSocketError: WebSocketError)
}

public func ==(lhs: WebSocketEvent, rhs: WebSocketEvent) -> Bool {
    switch (lhs, rhs) {
        case (.authenticated, .authenticated):
            return true
        case (.connected, .connected):
            return true
        case (let .disconnected(error1), let .disconnected(error2)):
            return error1 == error2
        case (let .serverError(error1), let .serverError(error2)):
            return error1 == error2
        default:
            return false
    }
}
