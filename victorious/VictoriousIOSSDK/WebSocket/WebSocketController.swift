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
/// 2. Receive messages over the WebSocket.
/// 3. Send messages over the WebSocket.
/// 4. Forward messages using the Forum Event Chain.
/// 5. It complies to the TemplateNetworkSource protocol so it can be instantiated through the template.
public class WebSocketController: WebSocketDelegate, ForumNetworkSourceWebSocket, WebSocketEventDecoder, WebSocketPongDelegate {

    private struct Constants {
        static let forceDisconnectTimeout: TimeInterval = 2
    }
    
    /// Custom background queue for packing and unpacking messages over the WebSocket.
    private lazy var socketListenerQueue: DispatchQueue = {
        DispatchQueue(label: "com.victorious.socket_listener")
    }()
    
    /// The actual instance which has a WebSocket connection.
    private var webSocket: WebSocket?
    
    /// The timer that will fire at a specified interval to keep the connection alive.
    private var pingTimer: Timer?

    /// If the client disconnects we still get the disconnect event, this flag is there to help avoid passsing that event on.
    private var clientInitiatedDisconnect = false
    
    /// The interval to send of ping messages.
    private let pingTimerInterval: TimeInterval = 15

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

    public func replaceEndPoint(endPoint: URL) {
        Log.verbose("WebSocket replaceEndPoint -> \(endPoint)")

        if let webSocket = webSocket {
            webSocket.disconnect()
        }

        webSocket = nil
        webSocket = WebSocket(url: endPoint, socketListenerQueue: socketListenerQueue, delegate: self, pongDelegate: self)
    }

    public func setDeviceID(deviceID: String) {
        Log.verbose("WebSocket setDeviceID -> \(deviceID)")
        uniqueIdentificationMessage.deviceID = deviceID
    }

    public private(set) var webSocketMessageContainer = WebSocketRawMessageContainer()

    // MARK: - ForumNetworkSource

    /// Tries to open the WebSocket connection to the specified endpoint in the configuration.
    /// A `WebSocketEvent` of type `.Connected` will be broadcasted if the connection succeeds.
    public func setUp() {
        guard let webSocket = webSocket , !webSocket.isConnected else {
            return
        }

        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(timeInterval: pingTimerInterval, target: self, selector: #selector(self.sendPing), userInfo: nil, repeats: true)
        
        webSocket.connect()
    }
    
    /// Sends the disconnect message to the server and waits for a certain amount of time before forcing the disconnect.
    /// When the disconnect has happened a `WebSocketEvent` of type `.disconnected` will be broadcasted.
    public func tearDown() {
        guard let webSocket = webSocket , webSocket.isConnected else {
            return
        }

        clientInitiatedDisconnect = true
        webSocket.disconnect(forceTimeout: Constants.forceDisconnectTimeout)
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
    
    public func send(_ event: ForumEvent) {
        sendOutbound(event)
    }
    
    // MARK: - WebSocketDelegate
    
    public func websocketDidConnect(socket: WebSocket) {
        Log.verbose("WebSocket did connect to URL -> \(socket.currentURL)")
        let rawMessage = WebSocketRawMessage(messageString: "Connected to URL -> \(socket.currentURL)")
        webSocketMessageContainer.add(rawMessage)

        DispatchQueue.main.async { [weak self] in
            self?.broadcast(.websocket(.connected))
        }
    }

    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        Log.verbose("WebSocket did disconnect from URL -> \(socket.currentURL) with error -> \(error)")
        let rawMessage = WebSocketRawMessage(messageString: "Disconnected -> \(socket) error -> \(error)")
        webSocketMessageContainer.add(rawMessage)
        
        // The WebSocket instance with the baked in token has been consumed. 
        // A new token has to be fetched and a new WebSocket instance has to be created.
        pingTimer?.invalidate()
        webSocket = nil

        if let disconnectEvent = eventFromDisconnect(error: error) {
            DispatchQueue.main.async { [weak self] in
                self?.broadcast(disconnectEvent)
            }
        }
    }

    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        Log.verbose("WebSocket did receive text message -> \(text)")
        var rawMessage = WebSocketRawMessage(messageString: "websocketDidReceiveMessage -> \(text)")

        if let dataFromString = text.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            rawMessage.json = json

            guard let event = (decodeEvent(from: json) ?? decodeError(from: json)) else {
                Log.info("Unparsable WebSocket message returned -> \(text)")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.broadcast(event)
            }
        }

        webSocketMessageContainer.add(rawMessage)
    }

    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        // ignore incoming data
    }
    
    // MARK: WebSocketPongDelegate
    
    public func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        let rawMessage = WebSocketRawMessage(messageString: "Did receive pong message.")
        webSocketMessageContainer.add(rawMessage)
    }

    // MARK: Private

    private func sendOutbound(_ event: ForumEvent) {
        switch event {
            case .sendContent(let content):
                sendJSON(from: content)
                bounceBackOutbound(event)
            case .blockUser(let blockUser):
                sendJSON(from: blockUser)
            default:
                break
        }
    }

    /// Will send outgoing content events back over the event chain.
    private func bounceBackOutbound(_ event: ForumEvent) {
        if case .sendContent(let content) = event {
            if content.author?.accessLevel.isCreator == true {
                broadcast(.showCaptionContent(content))
            }
            else {
                broadcast(.handleContent([content], .newer))
            }
        }
    }

    /// When the connection is closed we could get a custom error message from our backend OR it could be one generated by the system.
    /// We therefore first try to parse out the custom one and if that fails we go ahead and check for a system error.
    /// In the odd case that none of these exists we just create an empty disconnect event so the rest of the app knows that the connection is closed.
    private func eventFromDisconnect(error: NSError?) -> ForumEvent? {
        var disconnectEvent: ForumEvent?

        // According to the RFC even if the client disconnects we should receive a close message with the error code 1000.
        // We still want to broadcast that to the rest of the app but without an error so it's explicit nothing went wrong.
        if let error = error , clientInitiatedDisconnect && WebSocket.CloseCode(rawValue: UInt16(error.code)) == .normal {
            clientInitiatedDisconnect = false
            disconnectEvent = .websocket(.disconnected(webSocketError: nil))
        }
        else if let error = error, let errorMessageData = error.localizedDescription.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            // Try to parse out custom error message.
            let errorJSON = JSON(data: errorMessageData)
            if let webSocketError = decodeError(from: errorJSON, didDisconnect: true) {
                disconnectEvent = webSocketError
            }
        }

        // System generated error if all else fails.
        if disconnectEvent == nil {
            let webSocketError = WebSocketError.connectionTerminated(code: error?.code, message: error?.localizedDescription)
            disconnectEvent = ForumEvent.websocket(.disconnected(webSocketError: webSocketError))
        }

        return disconnectEvent
    }

    private func sendJSON(from dictionaryConvertible: DictionaryConvertible) {
        guard let webSocket = webSocket , webSocket.isConnected else {
            return
        }
        
        let toServerDictionary = dictionaryConvertible.toServerDictionary(with: uniqueIdentificationMessage)
        
        if let jsonString = JSON(toServerDictionary).rawString() {
            Log.verbose("sendOutboundForumEvent json -> \(jsonString)")
            webSocket.write(string: jsonString)
        }
        else {
            Log.warning("Failed to convert ForumEvent to JSON string. Dictionary -> \(toServerDictionary)")
        }
    }

    @objc private func sendPing() {
        guard let webSocket = webSocket , webSocket.isConnected else {
            return
        }
        webSocket.write(ping: Data())
    }
}

fileprivate extension WebSocket {
 
    /// Everytime the token is invalidated (== everytime we drop the connection) we have a need to generate a new connection
    /// and therefore also a new WebSocket instance. Since the token is appended to the URL.
    fileprivate convenience init(url: URL, socketListenerQueue: DispatchQueue? = nil, delegate: WebSocketDelegate? = nil, pongDelegate: WebSocketPongDelegate? = nil) {
        self.init(url: url, protocols: nil)
        self.delegate = delegate
        self.pongDelegate = pongDelegate

        if let socketListenerQueue = socketListenerQueue {
            self.callbackQueue = socketListenerQueue
        }
    }
}

fileprivate extension DictionaryConvertible {

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
    fileprivate func toServerDictionary(with identificationMessage: UniqueIdentificationMessage) -> [String: AnyObject] {
        var toServerDictionary: [String: AnyObject] = [:]

        if let rootTypeKey = rootTypeKey, let rootTypeValue = rootTypeValue {
            toServerDictionary[rootTypeKey] = rootTypeValue as AnyObject?
        }
        toServerDictionary[rootKey] = toDictionary() as AnyObject?

        var rootDictionary: [String: AnyObject] = [toServerTypeKey: toServerTypeValue as AnyObject]
        rootDictionary[identificationMessage.rootKey] = identificationMessage.toDictionary() as AnyObject?
        identificationMessage.incrementSequenceCounter()

        rootDictionary[toServerRootKey] = toServerDictionary as AnyObject?

        return rootDictionary
    }
}
