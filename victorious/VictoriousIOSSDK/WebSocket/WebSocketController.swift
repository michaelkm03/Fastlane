//
//  WebSocketController.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

///
/// A command sent *from* the cleint *to* the server.
///
/// NOTE: A `ServerCommand` very much looks like a `ClientCommand` but they are intentionally 
/// specified separate so they there can be no confusion between them.
///
public struct ServerCommand {

    // Required
    let id: String
    let functionName: String
    let timestamp: Timestamp

    // Optional
    let data: String?

    // MARK: - Initialization

    init(with json: JSON) throws {
        guard
            let id = json["id"].string,
            let functionName = json["functionName"].string,
            let timestamp = json["timestamp"].int64
            else {
                throw ResponseParsingError()
        }

        self.id = id
        self.functionName = functionName
        self.timestamp = Timestamp(value: timestamp)
        self.data = json["data"].string
    }
}

///
/// A command sent from the server *to* the client.
///
/// NOTE: A `ClientCommand` very much looks like a `ServerCommand` but they are intentionally
/// specified separate so they there can be no confusion between them.
///
public struct ClientCommand {

    // Required
    let id: String
    let functionName: String
    let timestamp: Timestamp

    // Optional
    let data: String?

    // MARK: - Initialization

    init(with json: JSON) throws {
        guard
            let id = json["id"].string,
            let functionName = json["functionName"].string,
            let timestamp = json["timestamp"].int64
        else {
            throw ResponseParsingError()
        }

        self.id = id
        self.functionName = functionName
        self.timestamp = Timestamp(value: timestamp)
        self.data = json["data"].string
    }
}



public class WebSocketController: WebSocketDelegate, ForumNetworkSource {

    // MARK: - Initialization

    init(with url: URL) {
        webSocketConnection = WebSocket(url: url)
        webSocketConnection.delegate = self
    }

    // MARK: - Private vars

    /// Custom background queue dedicated to sending and listening to WebSocket events.
    private lazy var socketListenerQueue: DispatchQueue = { DispatchQueue(label: "com.victorious.socket_listener") }()

    /// A reference to the instance which has the actual network connection.
    private let webSocketConnection: WebSocket

    /// The amount of time to wait for the disconnect message to be respected by the backend.
    private let forcedDisconnectTimeout = TimeInterval(2)


    // MARK: - WebSocketDelegate

    public func websocketDidConnect(socket: WebSocket) {
        Log.verbose("WebSocket did connect to URL -> \(socket.currentURL)")


//        let rawMessage = WebSocketRawMessage(messageString: "Connected to URL -> \(socket.currentURL)")
//        webSocketMessageContainer.add(rawMessage)

        DispatchQueue.main.async { [weak self] in
            self?.broadcast(.websocket(.connected))
        }
    }

    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        Log.verbose("WebSocket did disconnect from URL -> \(socket.currentURL) with error -> \(error)")

//        let rawMessage = WebSocketRawMessage(messageString: "Disconnected -> \(socket) error -> \(error)")
//        webSocketMessageContainer.add(rawMessage)
//
//        // The WebSocket instance with the baked in token has been consumed.
//        // A new token has to be fetched and a new WebSocket instance has to be created.
//        pingTimer?.invalidate()
//        webSocket = nil
//
//        if let disconnectEvent = eventFromDisconnect(error: error) {
//            DispatchQueue.main.async { [weak self] in
//                self?.broadcast(disconnectEvent)
//            }
//        }
    }

    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        Log.verbose("WebSocket did receive text message -> \(text)")

//        var rawMessage = WebSocketRawMessage(messageString: "websocketDidReceiveMessage -> \(text)")
//
//        if let dataFromString = text.data(using: String.Encoding.utf8, allowLossyConversion: false) {
//            let json = JSON(data: dataFromString)
//            rawMessage.json = json
//
//            guard let event = (decodeEvent(from: json) ?? decodeError(from: json)) else {
//                Log.info("Unparsable WebSocket message returned -> \(text)")
//                return
//            }
//
//            DispatchQueue.main.async { [weak self] in
//                self?.broadcast(event)
//            }
//        }
//
//        webSocketMessageContainer.add(rawMessage)
    }

    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        Log.verbose("WebSocket did receive data of count -> \(data.count)")
        // ignore incoming data
    }


    // MARK: - ForumNetworkSource

    /// Tries to open the WebSocket connection to the previously specified endpoint.
    /// A `WebSocketEvent` of type `.Connected` will be broadcasted if the connection succeeds.
    /// If the connection already is open then this call will be ignored.
    public func setUp() {
        guard !webSocketConnection.isConnected else {
            return
        }

        webSocketConnection.connect()
    }

    /// Is the WebSocket connection open at the moment?
    public var isSetUp: Bool {
        return webSocketConnection.isConnected == true
    }

    /// Sends the disconnect message to the server and waits for a certain amount of time before forcing the disconnect.
    /// When the disconnect has happened a `.disconnected` event will be broadcasted.
    public func tearDown() {
        guard webSocketConnection.isConnected else {
            return
        }

        webSocketConnection.disconnect(forceTimeout: forcedDisconnectTimeout)
    }

    public func addChildReceiver(_ receiver: ForumEventReceiver) {
        if (!childEventReceivers.contains { $0 === receiver }) {
            childEventReceivers.append(receiver)
        }
    }

    public func removeChildReceiver(_ receiver: ForumEventReceiver) {
        if let index = childEventReceivers.index( where: { $0 === receiver } ) {
            childEventReceivers.remove(at: index)
        }
    }

    // MARK: - ForumEventReceiver

    public private(set) var childEventReceivers: [ForumEventReceiver] = []

    public func receive(_ event: ForumEvent) { }

    // MARK: - ForumEventSender

    /// The `WebSocketController` has no `nextSender` since it's the last link in the chain.
    /// Messages reaching `WebSocketController` will be piped over the WebSocket.
    public let nextSender: ForumEventSender? = nil

    public func send(_ event: ForumEvent) {
//        sendOutbound(event)
    }


}


/*

//
//  VictoriousWebSocketEndpoint.swift
//  victorious
//
//  Created by Sebastian Nystorm on 15/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  This components specifies the WebSocket endpoint and contains all the information needed for opening a connection.
 */
public struct WebSocketConfiguration {
    private let endPoint: String
    private let port: UInt?
    private let serviceVersion: String?

    /// The amount of time to wait for the disconnect message to be respected by the backend.
    let forceDisconnectTimeout: TimeInterval

    let appId: String

    /// The initial part of the URL without the token appended.
    let baseUrl: URL

    init?(endPoint: String, appId: String, port: UInt? = nil, serviceVersion: String? = nil, forceDisconnectTimeout: TimeInterval = 5) {
        self.endPoint = endPoint
        self.port = port
        self.serviceVersion = serviceVersion
        self.forceDisconnectTimeout = forceDisconnectTimeout
        self.appId = appId

        let urlString = "\(endPoint):\(port)"
        guard var url = URL(string: urlString) else {
            return nil
        }

        if let serviceVersion = serviceVersion {
            url.appendPathComponent(serviceVersion)
        }

        url.appendPathComponent(appId)

        self.baseUrl = url
    }

    /// Since the token only can be used once to connect, use this function to generate a URL with the specified token.
    public func generateUrlFromToken(token: String) -> URL? {
        return baseUrl.appendingPathComponent(token)
    }
}

// MARK: - Chat Service Extension
public extension WebSocketConfiguration {

    private struct ChatServiceConstants {
        static let chatServiceEndPoint = "ws://ec2-52-53-214-56.us-west-1.compute.amazonaws.com"
//        static let chatServicePort = UInt(8063)
        static let chatServiceVersion = "v1"
        static let forceDisconnectTimeout = TimeInterval(5)
        static let appId = "1"
    }

    /**
     The default configuration for connecting to the Victorious chat service.

     - returns: A configuration instance that points to our remote servers.
     */
    public static func makeChatServiceWebSocketConfiguration() -> WebSocketConfiguration {
        let configuration = WebSocketConfiguration(
            endPoint: ChatServiceConstants.chatServiceEndPoint,
//            port: ChatServiceConstants.chatServicePort,
            serviceVersion: ChatServiceConstants.chatServiceVersion,
            forceDisconnectTimeout: ChatServiceConstants.forceDisconnectTimeout,
            appId: ChatServiceConstants.appId)
        return configuration!
    }
}

// MARK: - Local Web Socket
public extension WebSocketConfiguration {

    private struct LocalChatServiceConstants {
        static let chatServiceEndPoint = "ws://localhost"
        static let chatServicePort = UInt(8063)
        static let chatServiceVersion = "v1"
        static let forceDisconnectTimeout = TimeInterval(1)
        static let appId = "1"
    }

    /**
     A configuration that points to localhost to test out the chat service without the need for a remote server.

     - returns: A configuration instance that points to the local machine.
     */
    public static func makeLocalWebSocketConfiguration() -> WebSocketConfiguration {
        let configuration = WebSocketConfiguration(
            endPoint: LocalChatServiceConstants.chatServiceEndPoint,
            port: LocalChatServiceConstants.chatServicePort,
            serviceVersion: LocalChatServiceConstants.chatServiceVersion,
            forceDisconnectTimeout: LocalChatServiceConstants.forceDisconnectTimeout,
            appId: LocalChatServiceConstants.appId)
        return configuration!
    }
}

*/
