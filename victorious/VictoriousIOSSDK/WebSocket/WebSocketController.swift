import Foundation

///
/// A class used for connecting over WebSocket to a specific endpoint. It uses `ForumEvent`s to broadcast
/// what goes on over the socket such as: connected, disconnected & feed messages etc.
///
public class WebSocketController: WebSocketDelegate, ForumNetworkSource {

    // MARK: - Initialization

    init(with url: URL) {
        webSocketConnection = WebSocket(url: url)
        webSocketConnection.delegate = self
    }

    // MARK: - Public vars

    public private(set) var webSocketMessageContainer = WebSocketRawMessageContainer()

    // MARK: - Private vars

    /// Custom background queue dedicated to sending and listening to WebSocket events.
    private lazy var socketListenerQueue: DispatchQueue = { DispatchQueue(label: "com.victorious.socket_listener") }()

    /// A reference to the instance which has the actual network connection.
    private let webSocketConnection: WebSocket

    /// The amount of time to wait for the disconnect message to be respected by the backend.
    private let forcedDisconnectTimeout = TimeInterval(2)

    // MARK: - WebSocketDelegate

    public func websocketDidConnect(socket: WebSocket) {
        logEvent(event: "Connected to URL -> \(socket.currentURL)")

        DispatchQueue.main.async { [weak self] in
            self?.broadcast(.websocket(.connected))
        }
    }

    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        logEvent(event: "Disconnected from URL -> \(socket) error -> \(error)")
    }

    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        logEvent(event: "Did receive text message -> \(text)")
    }

    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        logEvent(event: "Did unexpectedly receive data of count -> \(data.count)")
        // ignore incoming data intentionally
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
        return webSocketConnection.isConnected
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
        // FUTURE: send the message through the chain
    }

    // MARK: Private

    /// Will write the event to a log using our log framework and to the message container (debug menu).
    private func logEvent(event: String) {
        Log.verbose(event)

        let rawMessage = WebSocketRawMessage(messageString: event)
        webSocketMessageContainer.add(rawMessage)
    }
}
