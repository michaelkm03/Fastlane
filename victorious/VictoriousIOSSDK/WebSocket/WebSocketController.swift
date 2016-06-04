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
public class WebSocketController: WebSocketDelegate, ForumNetworkSourceWebSocket, WebSocketEventDecoder, WebSocketPongDelegate {

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

    /// Keeps record of the information needed in order to identify each message.
    internal let uniqueIdentificationMessage = UniqueIdentificationMessage()

    /// The designated way of getting a reference to the singleton instance with the default configuration.
    public static let sharedInstance = WebSocketController()

    // MARK: Initialization

    /// Use this initializer only for testing purposes. Otherwise access the single instance through `sharedInstance`.
    ///
    /// - returns: Returns an instance of the WebSocketController configured to the specified endpoint.
    internal init(webSocket: WebSocket? = nil) {
        self.webSocket = webSocket
    }

    // MARK: - ForumNetworkSourceWebSocket

    public func replaceEndPoint(endPoint: NSURL) {
        print("replaceEndPoint -> ", endPoint)

        if let webSocket = webSocket {
            webSocket.disconnect()
        }

        webSocket = nil
        webSocket = WebSocket(url: endPoint, socketListenerQueue: socketListenerQueue, delegate: self, pongDelegate: self)
    }

    public func setDeviceID(deviceID: String) {
        print("setDeviceID -> \(deviceID)")
        uniqueIdentificationMessage.deviceID = deviceID
    }

    public private(set) var webSocketMessageContainer = WebSocketRawMessageContainer()

    // MARK: - ForumNetworkSource

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
        if (!childEventReceivers.contains { $0 === receiver }) {
            childEventReceivers.append(receiver)
        }
    }

    public func removeChildReceiver(receiver: ForumEventReceiver) {
        if let index = childEventReceivers.indexOf( { $0 === receiver } ) {
            childEventReceivers.removeAtIndex(index)
        }
    }
    
    /// Is the WebSocket connection open at the moment?
    public var isSetUp: Bool {
        return webSocket?.isConnected == true
    }
    
    // MARK: - ForumEventReceiver

    public private(set) var childEventReceivers: [ForumEventReceiver] = []

    // MARK: - ForumEventSender

    /// The `WebSocketController` has no `nextSender` since it's the last link in the chain.
    /// Messages reaching `WebSocketController` will be piped over the WebSocket.
    public let nextSender: ForumEventSender? = nil
    
    public func send(event: ForumEvent) {
        sendOutboundForumEvent(event)
    }
    
    // MARK: - WebSocketDelegate
    
    public func websocketDidConnect(socket: WebSocket) {
        let rawMessage = WebSocketRawMessage(messageString: "Connected to URL -> \(socket.currentURL)")
        webSocketMessageContainer.addMessage(rawMessage)
        
        let connectEvent = WebSocketEvent.Connected
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.broadcast(.websocket(connectEvent))
        }
    }

    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        let rawMessage = WebSocketRawMessage(messageString: "Disconnected -> \(socket) error -> \(error)")
        webSocketMessageContainer.addMessage(rawMessage)
        
        // The WebSocket instance with the baked in token has been consumed. 
        // A new token has to be fetched and a new WebSocket instance has to be created.
        webSocket = nil
        pingTimer?.invalidate()
        
        let webSocketError = WebSocketError.ConnectionTerminated(code: error?.code, error: error)
        let disconnectEvent = WebSocketEvent.Disconnected(webSocketError: webSocketError)
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.broadcast(.websocket(disconnectEvent))
        }
    }

    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        var rawMessage = WebSocketRawMessage(messageString: "websocketDidReceiveMessage -> \(text)")

        if let dataFromString = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            rawMessage.json = json

            if let event = decodeEventFromJSON(json) {
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    self?.broadcast(event)
                }
            }
        }

        webSocketMessageContainer.addMessage(rawMessage)
    }

    public func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        // ignore incoming data
    }
    
    // MARK: WebSocketPongDelegate
    
    public func websocketDidReceivePong(socket: WebSocket) {
        let rawMessage = WebSocketRawMessage(messageString: "Did receive pong message.")
        webSocketMessageContainer.addMessage(rawMessage)
    }

    // MARK: Private

    private func sendOutboundForumEvent(event: ForumEvent) {
        switch event {
        case .sendContent(let content):
            sendJSON(from: content)
            bounceBackOutboundEvent(event)
        case .blockUser(let blockUser):
            sendJSON(from: blockUser)
        default:
            break
        }
    }

    /// Will send outgoing content events back over the event chain.
    private func bounceBackOutboundEvent(event: ForumEvent) {
        if case .sendContent(let content) = event {
            broadcast(.appendContent([content]))
        }
    }

    private func sendJSON(from dictionaryConvertible: DictionaryConvertible) {
        guard let webSocket = webSocket where webSocket.isConnected else {
            return
        }
        
        let toServerDictionary = dictionaryConvertible.toServerDictionaryWithIdentificationMessage(uniqueIdentificationMessage)
        
        if let jsonString = JSON(toServerDictionary).rawString() {
            NSLog("sendOutboundForumEvent json -> \(jsonString)")
            webSocket.writeString(jsonString)
        } else {
            NSLog("Failed to convert ForumEvent to JSON string. Dictionary -> \(toServerDictionary)")
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

private extension DictionaryConvertible {

    private var toServerRootKey: String {
        return "to_server"
    }

    private var toServerTypeKey: String {
        return "type"
    }

    private var toServerTypeValue: String {
        return "TO_SERVER"
    }

    /// A dictionary representation of the WebSocket JSON protocol. The `identificationMessage` is passed in to identify each outgoing message.
    private func toServerDictionaryWithIdentificationMessage(identificationMessage: UniqueIdentificationMessage) -> [String: AnyObject] {
        var toServerDictionary: [String: AnyObject] = [:]

        if let rootTypeKey = rootTypeKey, let rootTypeValue = rootTypeValue {
            toServerDictionary[rootTypeKey] = rootTypeValue
        }
        toServerDictionary[rootKey] = toDictionary()

        var rootDictionary: [String: AnyObject] = [toServerTypeKey: toServerTypeValue]
        rootDictionary[identificationMessage.rootKey] = identificationMessage.toDictionary()
        identificationMessage.incrementSequenceCounter()

        rootDictionary[toServerRootKey] = toServerDictionary

        return rootDictionary
    }
}
