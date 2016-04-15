//
//  WebSocketController.swift
//  victorious
//
//  Created by Sebastian Nystorm on 15/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//


/// The WebSocketController is the one stop shop for talking and listening over a WebSocket.
///
/// It features are:
/// 1. Open/Close a websocket connection using a configuration.
/// 2. Receive messages over the websocket.
/// 3. Send messages over the websocket.
/// 4. Forward messages using the (FEC) Forum Event Chain™.
/// 5. It complies to the TemplateNetworkSource protocol so it can be instanciated through the template.
public class WebSocketController: WebSocketDelegate, NetworkSourceWebSocket, WebSocketEventDecoder, WebSocketPongDelegate {

    private struct Constants {
        static let forceDisconnectTimeout: NSTimeInterval = 5
    }
    
    /// Custom background queue for packing and unpacking messages over the WebSocket.
    private lazy var socketListenerQueue: dispatch_queue_t = {
        dispatch_queue_create("com.victorious.socket_listener", DISPATCH_QUEUE_SERIAL)
    }()
    
    /// The actual instance which has a WebSocket connection.
    private var webSocket: WebSocket?
    
    /// The timer that will fire at a specified interval to keep the connection alive.
    private var pingTimer: NSTimer?
    
    /// The interval to send of ping messages.
    private let pingTimerInterval: NSTimeInterval = 15

    /// The designated way of getting a reference to the singleton instance with the default configuration.
    public static let sharedInstance: WebSocketController = WebSocketController()

    // MARK: Initialization

    /// Use this initializer only for testing purposes. Otherwise access the single instance through `sharedInstance`.
    ///
    /// - returns: Returns an instance of the WebSocketController configured to the specified endpoint.
    internal init(webSocket: WebSocket? = nil) {
        self.webSocket = webSocket
    }

    // MARK: - NetworkSourceWebSocket
    
    /// Is the WebSocket connection open at the moment.
    public var isConnected: Bool {
        guard let webSocket = webSocket where webSocket.isConnected else {
            return false
        }
        return true
    }
    
    // MARK: - TemplateNetworkSource
    
    public func replaceEndPoint(endPoint: NSURL) {
        print("replaceEndPoint -> ", endPoint)
        
        if let webSocket = webSocket {
            webSocket.disconnect()
        }
        
        webSocket = nil
        webSocket = WebSocket(url: endPoint, socketListenerQueue: socketListenerQueue, delegate: self, pongDelegate: self)
    }
    
    /// Tries to open the WebSocket connection to the specified endpoint in the configuration.
    /// A `WebSocketEvent` of type `.Connected` will be broadcasted if the connection succeeds.
    public func setUp() {
        guard let webSocket = webSocket where !webSocket.isConnected else {
            return
        }
        
        pingTimer?.invalidate()
        pingTimer = NSTimer.scheduledTimerWithTimeInterval(pingTimerInterval, target: self, selector: #selector(self.sendPing), userInfo: nil, repeats: true)
        
        webSocket.connect()
    }
    
    /// Sends the disconnect message to the server and waits for a certain amount of time before forcing the disconnect.
    /// When the disconnect has happened a `WebSocketEvent` of type `.Disconnected` will be broadcasted.
    public func tearDown() {
        guard let webSocket = webSocket where webSocket.isConnected else {
            return
        }
        webSocket.disconnect(forceTimeout: Constants.forceDisconnectTimeout)
    }
    
    public func addChildReceiver(receiver: ForumEventReceiver) {
        childEventReceivers.append(receiver)
    }
    
    // MARK: - ForumEventReceiver
    
    public var childEventReceivers: [ForumEventReceiver] = []
    
    // MARK: - ForumEventSender

    /// The `WebSocketController` has no `nextSender` since it's the last link in the chain.
    /// Messages reaching `WebSocketController` will be piped over the WebSocket.
    public let nextSender: ForumEventSender? = nil
    
    public func sendEvent(event: ForumEvent) {
        sendOutboundForumEvent(event)
    }
    
    // MARK: - WebSocketDelegate
    
    public func websocketDidConnect(socket: WebSocket) {
        NSLog("websocketDidConnect")
        
        let connectEvent = WebSocketEvent(type: .Connected)
        dispatch_async(dispatch_get_main_queue()) {
            self.receiveEvent(connectEvent)
        }
    }

    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        NSLog("DidDisconnect -> \(socket)    error -> \(error)")
        
        // The WebSocket instance with the baked in token has been consumed. 
        // A new token has to be fetched and a new WebSocket instance has to be created.
        webSocket = nil
        
        let webSocketError = WebSocketError.ConnectionTerminated(code: error?.code, error: error)
        let disconnectEvent = WebSocketEvent(type: WebSocketEventType.Disconnected(webSocketError: webSocketError))
        
        dispatch_async(dispatch_get_main_queue()) {
            self.receiveEvent(disconnectEvent)
        }
    }

    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        NSLog("websocketDidReceiveMessage -> \(text)")
        
        if let dataFromString = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            let events = decodeEventsFromJson(json)
            for event in events {
                receiveEvent(event)
            }
        }
    }

    public func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        // ignore incoming data
    }
    
    // MARK: WebSocketPongDelegate
    
    public func websocketDidReceivePong(socket: WebSocket) {
        NSLog("websocketDidReceivePong")
    }

    // MARK: Private

    private func sendOutboundForumEvent(event: ForumEvent) {
        guard let webSocket = webSocket where webSocket.isConnected else {
            return
        }
        
        guard let dictionaryConvertible = event as? DictionaryConvertible else {
            assertionFailure("Failed to convert DictionaryConvertible ForumEvent to JSON string. event -> \(event)")
            return
        }
        
        let toServerDictionary = [
            "to_server": [
                dictionaryConvertible.defaultKey: dictionaryConvertible.toDictionary()
            ]
        ]
        if let jsonString = JSON(toServerDictionary).rawString() {
            NSLog("sendOutboundForumEvent json -> ", jsonString)
            webSocket.writeString(jsonString)
            receiveEvent(event)
        } else {
            assertionFailure("Failed to convert JSONConvertable ForumEvent to JSON string. event -> \(event)")
        }
    }

    @objc private func sendPing() {
        guard let webSocket = webSocket where webSocket.isConnected else {
            return
        }
        webSocket.writePing(NSData())
    }
}

private extension WebSocket {
 
    /// Everytime the token is invalidated (== everytime we drop the connection) we have a need to generate a new connection
    /// and therefore also a new WebSocket instance. Since the token is appended to the URL.
    private convenience init(url: NSURL, socketListenerQueue: dispatch_queue_t? = nil, delegate: WebSocketDelegate? = nil, pongDelegate: WebSocketPongDelegate? = nil) {
        self.init(url: url, protocols: nil)
        self.queue = socketListenerQueue
        self.delegate = delegate
        self.pongDelegate = pongDelegate
    }
}
