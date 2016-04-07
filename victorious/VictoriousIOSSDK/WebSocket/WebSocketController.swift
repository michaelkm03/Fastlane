//
//  WebSocketController.swift
//  victorious
//
//  Created by Sebastian Nystorm on 15/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/**
 *  The WebSocketController is the one stop shop for talking and listening over a WebSocket.
 *  It features are
 *  1. Open/Close a websocket connection using a configuration.
 *  2. Receive messages over the websocket.
 *  3. Send messages over the websocket.
 *  4. Forward messages using the (FEC) Forum Event Chain™.
 *  5. It complies to the TemplateNetworkSource protocol so it can be instanciated through the template.
 */
public class WebSocketController: WebSocketDelegate, TemplateNetworkSource, WebSocketEventDecoder {

    /// Is the WebSocket connection open at the moment.
    public var isConnected: Bool {
        guard let webSocket = webSocket where webSocket.isConnected else {
            return false
        }
        return true
    }

    /// The token used for authentication the application in this session. Once the WebSocket it closed the token is obsolete.
    private var currentToken: String?
    
    /// Custom background queue for packing and unpacking messages over the WebSocket.
    private lazy var socketListenerQueue: dispatch_queue_t = {
        dispatch_queue_create("com.victorious.socket_listener", DISPATCH_QUEUE_SERIAL)
    }()

    private let webSocketConfiguration: WebSocketConfiguration
    
    private var webSocket: WebSocket?
    
    /// The designated way of getting a reference to the singleton instance with the default configuration.
    public static let sharedInstance: WebSocketController = WebSocketController(webSocketConfiguration: WebSocketConfiguration.makeChatServiceWebSocketConfiguration())

    // MARK: Initialization
    
    /**
    Use this initializer only for testing purposes. Otherwise access the single instance through `sharedInstance`.
    
    - parameter webSocketConfiguration: Configuration object for specifying the end point.
    
    - returns: Returns an instance of the WebSocketController configured to the specified endpoint.
    */
    internal init(webSocketConfiguration: WebSocketConfiguration, webSocket: WebSocket? = nil, token: String? = nil) {
        self.webSocketConfiguration = webSocketConfiguration
        self.webSocket = webSocket
    }

    // MARK: - Public
    // MARK: - TemplateNetworkSource
    
    /**
    Replaces the current one use token. This will close the websocket if it is already open.
    
    - parameter token: A token string of length > 0.
    */
    public func replaceToken(token: String) {
        if token.characters.count > 0 {
            if let webSocket = webSocket {
                webSocket.disconnect()
            }
            webSocket = nil
            currentToken = token
            
            webSocket = WebSocket(configuration: webSocketConfiguration, token: token, socketListenerQueue: socketListenerQueue, delegate: self)
        }
    }

    /**
        Tries to open the WebSocket connection to the specified endpoint in the configuration.
        A `WebSocketEvent` of type `.Connected` will be broadcasted if the connection succeeds.
    */
    public func connect() {
        guard let webSocket = webSocket where !webSocket.isConnected else {
            return
        }
        webSocket.connect()
    }
    
    /**
        Sends the disconnect message to the server and waits for a certain amount of time before forcing the disconnect.
        When the disconnect has happened a `WebSocketEvent` of type `.Disconnected` will be broadcasted.
     */
    public func disconnect() {
        guard let webSocket = webSocket where webSocket.isConnected else {
            return
        }
        webSocket.disconnect(forceTimeout: webSocketConfiguration.forceDisconnectTimeout)
    }
    
    public func addChildReceiver(receiver: ForumEventReceiver) {
        childEventReceivers.append(receiver)
    }
    
    
    // MARK: - ForumEventReceiver
    
    public var childEventReceivers: [ForumEventReceiver] = []

    
    // MARK: - ForumEventSender

    /// The `WebSocketController` has no `nextSender` since it's the last link in the chain.
    /// Messages reaching `WebSocketController` will be piped over the WebSocket.
    public var nextSender: ForumEventSender? = nil
    
    public func sendEvent(event: ForumEvent) {
        sendOutboundForumEvent(event)
    }
    
    
    // MARK: - WebSocketDelegate
    
    public func websocketDidConnect(socket: WebSocket) {
        let connectEvent = WebSocketEvent(type: .Connected)
        broadcastForumEvent(connectEvent)
    }
    
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        // The token has been consumed and a new one is needed.
        currentToken = nil

        let webSocketError = WebSocketError.ConnectionTerminated(code: error?.code, error: error)
        let disconnectEvent = WebSocketEvent(type: WebSocketEventType.Disconnected(webSocketError: webSocketError))
        broadcastForumEvent(disconnectEvent)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        if let dataFromString = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            let events = decodeEventsFromJson(json)
            for event in events {
                broadcastForumEvent(event)
            }
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        // ignore incoming data
    }
    
    
    // MARK: - Private
    
    private func broadcastForumEvent(event: ForumEvent) {
        for child in childEventReceivers {
            dispatch_async(dispatch_get_main_queue()) {
                child.receiveEvent(event)
            }
        }
    }

    private func sendOutboundForumEvent(event: ForumEvent) {
        guard let webSocket = webSocket where webSocket.isConnected else {
            return
        }
        
        if let event = event as? JSONConvertable {
            let toServerPackage = JSON(["to_server": event.toJSON()])
            if let jsonString = toServerPackage.rawString() {
                webSocket.writeString(jsonString)
            } else {
                assertionFailure("Failed to convert JSONConvertable ForumEvent to JSON string. event -> \(event)")
            }
        }
    }
}

private extension WebSocket {
 
    /// Everytime the token is invalidated (== everytime we drop the connection) we have a need to generate a new connection
    /// and therefore also a new WebSocket instance. Since the token is appended to the URL.
    private convenience init(configuration: WebSocketConfiguration, token: String, socketListenerQueue: dispatch_queue_t? = nil, delegate: WebSocketDelegate? = nil) {
        let url = configuration.generateUrlFromToken(token)
        self.init(url: url)
        self.queue = socketListenerQueue
        self.delegate = delegate
    }
}
