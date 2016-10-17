//
//  VIPWebSocketControllerTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 15/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class VIPWebSocketControllerTests: XCTestCase, ForumEventReceiver, ForumEventSender {
    fileprivate var controller: VIPWebSocketController!
    fileprivate var webSocket: StubbedWebSocket!
    
    // ForumEventSender
    var nextSender: ForumEventSender?
    
    // Expectations
    var expectationConnectEvent: XCTestExpectation?
    var expectationAuthenticationEvent: XCTestExpectation?
    var expectationDisconnectedEvent: XCTestExpectation?
    var expectationIncomingChatMessage: XCTestExpectation?
    var expectationRefreshStageMessage: XCTestExpectation?
    var expectationChatUserCountEvent: XCTestExpectation?


    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()

        webSocket = StubbedWebSocket()
        controller = VIPWebSocketController(webSocket: webSocket)
        webSocket.delegate = controller
    }
    
    override func tearDown() {
        // Reset all test expectations so they don't interfere.
        expectationConnectEvent = nil
        expectationAuthenticationEvent = nil
        expectationDisconnectedEvent = nil
        expectationIncomingChatMessage = nil
        expectationRefreshStageMessage = nil
        expectationChatUserCountEvent = nil

        // Brake the retain loop.
        controller = nil
        nextSender = nil
        
        super.tearDown()
    }
    
    func testWebSocketConnectEvent() {
        nextSender = controller
        controller.addChildReceiver(self)
        
        XCTAssertFalse(controller.isSetUp, "Expected controller to NOT be set up after initialization.")
        
        expectationConnectEvent = expectation(description: "WebSocket-connect-event")
        controller.setUp()
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWebSocketDisconnectEvents() {
        nextSender = controller
        controller.addChildReceiver(self)
        
        webSocket.connect()
        XCTAssertTrue(controller.isSetUp, "Expected controller to be set up in order to test out the disconnect event.")

        expectationDisconnectedEvent = expectation(description: "WebSocket-disconnect-event")
        controller.tearDown()
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWebSocketInboundChatMessage() {
        nextSender = controller
        controller.addChildReceiver(self)
        
        guard let mockChatMessageURL = Bundle(for: type(of: self)).url(forResource: "InboundWebsocketEvent", withExtension: "json"),
            let mockChatMessageString = try? String(contentsOf: mockChatMessageURL, encoding: String.Encoding.utf8) else {
                XCTFail("Error reading mock JSON data for InboundChatMessage.")
                return
        }
        expectationIncomingChatMessage = expectation(description: "WebSocket-incoming-chat-message")
        controller.websocketDidReceiveMessage(socket: webSocket, text: mockChatMessageString)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWebSocketOutboundChatMessage() {
        nextSender = controller
        
        let user = User(id: 1222, displayName: "username")
        let chatMessageOutbound = Content(
            author: user,
            createdAt: Timestamp(value: 1234567890),
            text: "Test chat message"
        )

        let identificationMessage = controller.uniqueIdentificationMessage

        var toServerDictionary: [String: AnyObject] = [chatMessageOutbound.rootTypeKey!: chatMessageOutbound.rootTypeValue! as AnyObject]
        toServerDictionary[chatMessageOutbound.rootKey] = chatMessageOutbound.toDictionary() as AnyObject?
        var rootDictionary: [String: AnyObject] = ["type": "TO_SERVER" as AnyObject]
        rootDictionary[identificationMessage.rootKey] = identificationMessage.toDictionary() as AnyObject?
        rootDictionary["to_server"] = toServerDictionary as AnyObject?

        webSocket.chatMessageOutboundString = JSON(rootDictionary).rawString()
        webSocket.expectationOutboundChatMessage = expectation(description: "WebSocket-outgoing-chat-message")
        webSocket.connect()
        
        send(.sendContent(chatMessageOutbound))
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWebSocketBlockUserMessage() {
        nextSender = controller
        
        let blockUser = BlockUser(userID: "1337")
        let identificationMessage = controller.uniqueIdentificationMessage

        var toServerDictionary: [String: AnyObject] = [blockUser.rootTypeKey!: blockUser.rootTypeValue! as AnyObject]
        toServerDictionary[blockUser.rootKey] = blockUser.toDictionary() as AnyObject?
        var rootDictionary: [String: AnyObject] = ["type": "TO_SERVER" as AnyObject]
        rootDictionary[identificationMessage.rootKey] = identificationMessage.toDictionary() as AnyObject?
        rootDictionary["to_server"] = toServerDictionary as AnyObject?

        webSocket.blockUserString = JSON(rootDictionary).rawString()
        webSocket.expectationBlockUserMessage = expectation(description: "WebSocket-block-user-message")
        webSocket.connect()

        send(.blockUser(blockUser))
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWebSocketRefreshStage() {
        nextSender = controller
        controller.addChildReceiver(self)
        
        guard let mockStageMessageURL = Bundle(for: type(of: self)).url(forResource: "RefreshStage", withExtension: "json"),
            let mockStageMessageString = try? String(contentsOf: mockStageMessageURL, encoding: String.Encoding.utf8) else {
                XCTFail("Error reading mock JSON data for RefreshStage.")
                return
        }

        expectationRefreshStageMessage = expectation(description: "WebSocket-refresh-stage-message")
        controller.websocketDidReceiveMessage(socket: webSocket, text: mockStageMessageString)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testChatUsersCount() {
        nextSender = controller
        controller.addChildReceiver(self)

        guard let mockChatUserCountURL = Bundle(for: type(of: self)).url(forResource: "ChatUserCount", withExtension: "json"),
            let mockChatUserCountString = try? String(contentsOf: mockChatUserCountURL, encoding: String.Encoding.utf8) else {
                XCTFail("Error reading mock JSON data for ChatUserCount")
                return
        }

        expectationChatUserCountEvent = expectation(description: "WebSocket-chat-user-event")
        controller.websocketDidReceiveMessage(socket: webSocket, text: mockChatUserCountString)
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: ForumEventReceiver
    
    let childEventReceivers = [ForumEventReceiver]()
    
    func receive(_ event: ForumEvent) {
        switch event {
        case .websocket(let websocketEvent):
            switch websocketEvent {
            case .authenticated:
                expectationAuthenticationEvent?.fulfill()
            case .connected:
                guard let expectationConnectEvent = expectationConnectEvent else {
                    return
                }
                if controller.isSetUp {
                    expectationConnectEvent.fulfill()
                } else {
                    XCTFail("Expected VIPWebSocketController to be connected after the .connected event has been sent out.")
                }
            case .disconnected(webSocketError: _):
                guard let expectationDisconnectedEvent = expectationDisconnectedEvent else {
                    return
                }
                if !controller.isSetUp {
                    expectationDisconnectedEvent.fulfill()
                } else {
                    XCTFail("Expected VIPWebSocketController to NOT be connected after the .disconnect event has been sent out.")
                }
            default:
                XCTFail("Unexpected WebSocketEventType received. Type -> \(websocketEvent)")
            }
        case .handleContent(_, _):
            expectationIncomingChatMessage?.fulfill()
        case .refreshStage(_):
            expectationRefreshStageMessage?.fulfill()
        case .chatUserCount(_):
            expectationChatUserCountEvent?.fulfill()
        default:
            XCTFail("Unexpected ForumEvent type received. Event -> \(event)")
        }
    }
}

private class StubbedWebSocket: WebSocket {
    // Testing values to be compared to what gets passed into the `writeString:` function.
    var chatMessageOutboundString: String?
    var blockUserString: String!
    var expectationOutboundChatMessage: XCTestExpectation?
    var expectationBlockUserMessage: XCTestExpectation?
    
    init() { super.init(url: URL(string: "ws://this.url.is.fake")!) }
    
    override var isConnected: Bool { return _isConnected }
    fileprivate var _isConnected: Bool = false
    
    override func connect() {
        _isConnected = true
        delegate?.websocketDidConnect(socket: self)
    }

    override private func disconnect(forceTimeout: TimeInterval?, closeCode: UInt16) {
        delegate?.websocketDidDisconnect(socket: self, error: nil)
    }
    
    override func write(string: String, completion: (() -> ())?) {
        if let chatMessageOutboundString = chatMessageOutboundString , chatMessageOutboundString == string {
            expectationOutboundChatMessage?.fulfill()
        } else if let blockUserString = blockUserString , blockUserString == string {
            expectationBlockUserMessage?.fulfill()
        }
    }
}
