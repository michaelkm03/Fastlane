//
//  ForumNetworkSource.swift
//  victorious
//
//  Created by Sebastian Nystorm on 22/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public protocol ForumNetworkSource: ForumEventReceiver, ForumEventSender {
    ///
    /// Allows for adding child receivers from an external source.
    ///
    /// - parameter receiver: The receiver of `ForumEvent`.
    ///
    func addChildReceiver(_ receiver: ForumEventReceiver)

    ///
    /// Removal of specific child receiver. Holds a strong reference to receiver.
    ///
    func removeChildReceiver(_ receiver: ForumEventReceiver)

    ///
    /// The receiver will prepare any connections and make sure it is ready to be used.
    ///
    func setUp()
    
    ///
    /// The receiver will close any connections open and clean up after itself.
    ///
    func tearDown()
    
    /// Whether the network source is set-up and ready to use or not.
    var isSetUp: Bool { get }
}

extension ForumNetworkSource {
    /// Calls `setUp` if `isSetUp` returns false.
    public func setUpIfNeeded() {
        if !isSetUp {
            setUp()
        }
    }
}

// TODO: remove protocol
public protocol ForumNetworkSourceWebSocket: ForumNetworkSource {
    /// Used for tracking trafic over the websocket to a particular device. Should be set before messages are sent.
    func setDeviceID(deviceID: String)
    
    /// Replaces the endPoint used for opening a WebSocket connection. This URL has the use once token baked into it.
    /// - parameter endPoint: The actual URL to hit in the form: "ws:// or wss://"
    ///
    func replaceEndPoint(endPoint: URL)

    /// Will contain all incoming and outgoing messages over the WebSocket.
    var webSocketMessageContainer: WebSocketRawMessageContainer { get }
}
