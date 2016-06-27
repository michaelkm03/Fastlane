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
/// - Connected: The WebSocket connection is open.
/// - Disconnected: The WebSocket connection is closed with an error message.
/// - ServerError: A custom error message was sent from the backend.
public enum WebSocketEvent: Equatable {
    case Authenticated
    case Connected
    case Disconnected(webSocketError: WebSocketError)
    case ServerError(webSocketError: WebSocketError)
}

public func ==(lhs: WebSocketEvent, rhs: WebSocketEvent) -> Bool {
    switch (lhs, rhs) {
    case (.Authenticated, .Authenticated):
        return true
    case (.Connected, .Connected):
        return true
    case (let .Disconnected(error1), let .Disconnected(error2)):
        return error1 == error2
    case (let .ServerError(error1), let .ServerError(error2)):
        return error1 == error2
    default:
        return false
    }
}
