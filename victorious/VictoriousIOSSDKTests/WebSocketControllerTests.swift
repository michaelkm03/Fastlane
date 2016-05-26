//
//  WebSocketControllerTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 15/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class WebSocketControllerTests: XCTestCase, ForumEventReceiver, ForumEventSender {
    private var controller: WebSocketController!
    private var webSocket: StubbedWebSocket!
    
    // ForumEventSender
    var nextSender: ForumEventSender?
    
    // Expectations
    var expectationConnectEvent: XCTestExpectation?
    var expectationAuthenticationEvent: XCTestExpectation?
    var expectationDisconnectedEvent: XCTestExpectation?
    var expectationIncomingChatMessage: XCTestExpectation?
    var expectationRefreshStageMessage: XCTestExpectation?
    
    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()

        webSocket = StubbedWebSocket()
        controller = WebSocketController(webSocket: webSocket)
        webSocket.delegate = controller
    }
    
    override func tearDown() {
        // Reset all test expectations so they don't interfere.
        expectationConnectEvent = nil
        expectationAuthenticationEvent = nil
        expectationDisconnectedEvent = nil
        expectationIncomingChatMessage = nil
        expectationRefreshStageMessage = nil
        
        // Brake the retain loop.
        controller = nil
        nextSender = nil
        
        super.tearDown()
    }
    
    func testWebSocketConnectEvent() {
        nextSender = controller
        controller.addChildReceiver(self)
        
        XCTAssertFalse(controller.isSetUp, "Expected controller to NOT be set up after initialization.")
        
        expectationConnectEvent = expectationWithDescription("WebSocket-connect-event")
        controller.setUp()
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWebSocketDisconnectEvents() {
        nextSender = controller
        controller.addChildReceiver(self)
        
        webSocket.connect()
        XCTAssertTrue(controller.isSetUp, "Expected controller to be set up in order to test out the disconnect event.")

        expectationDisconnectedEvent = expectationWithDescription("WebSocket-disconnect-event")
        controller.tearDown()
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWebSocketInboundChatMessage() {
        nextSender = controller
        controller.addChildReceiver(self)
        
        guard let mockChatMessageURL = NSBundle(forClass: self.dynamicType).URLForResource("InboundWebsocketEvent", withExtension: "json"),
            let mockChatMessageString = try? String(contentsOfURL: mockChatMessageURL, encoding: NSUTF8StringEncoding) else {
                XCTFail("Error reading mock JSON data for InboundChatMessage.")
                return
        }
        expectationIncomingChatMessage = expectationWithDescription("WebSocket-incoming-chat-message")
        controller.websocketDidReceiveMessage(webSocket, text: mockChatMessageString)
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWebSocketOutboundChatMessage() {
        nextSender = controller
        
        let user = ChatMessageUser(id: 1222, name: "username", profileURL: NSURL())
        let chatMessageOutbound = ChatMessage(serverTime: NSDate(timeIntervalSince1970: 1234567890), fromUser: user, text: "Test chat message")!
        let identificationMessage = controller.uniqueIdentificationMessage

        var toServerDictionary: [String: AnyObject] = [chatMessageOutbound.rootTypeKey!: chatMessageOutbound.rootTypeValue!]
        toServerDictionary[chatMessageOutbound.rootKey] = chatMessageOutbound.toDictionary()
        var rootDictionary: [String: AnyObject] = ["type": "TO_SERVER"]
        rootDictionary[identificationMessage.rootKey] = identificationMessage.toDictionary()
        rootDictionary["to_server"] = toServerDictionary

        webSocket.chatMessageOutboundString = JSON(rootDictionary).rawString()
        webSocket.expectationOutboundChatMessage = expectationWithDescription("WebSocket-outgoing-chat-message")
        webSocket.connect()
        
        sendEvent(chatMessageOutbound)
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWebSocketBlockUserMessage() {
        nextSender = controller
        
        let blockUser = BlockUser(serverTime: NSDate(timeIntervalSince1970: 1234567890), userID: "1337")
        let identificationMessage = controller.uniqueIdentificationMessage

        var toServerDictionary: [String: AnyObject] = [blockUser.rootTypeKey!: blockUser.rootTypeValue!]
        toServerDictionary[blockUser.rootKey] = blockUser.toDictionary()
        var rootDictionary: [String: AnyObject] = ["type": "TO_SERVER"]
        rootDictionary[identificationMessage.rootKey] = identificationMessage.toDictionary()
        rootDictionary["to_server"] = toServerDictionary

        webSocket.blockUserString = JSON(rootDictionary).rawString()
        webSocket.expectationBlockUserMessage = expectationWithDescription("WebSocket-block-user-message")
        webSocket.connect()

        sendEvent(blockUser)
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWebSocketRefreshStage() {
        nextSender = controller
        controller.addChildReceiver(self)
        
        guard let mockStageMessageURL = NSBundle(forClass: self.dynamicType).URLForResource("RefreshStage", withExtension: "json"),
            let mockStageMessageString = try? String(contentsOfURL: mockStageMessageURL, encoding: NSUTF8StringEncoding) else {
                XCTFail("Error reading mock JSON data for RefreshStage.")
                return
        }

        expectationRefreshStageMessage = expectationWithDescription("WebSocket-refresh-stage-message")
        controller.websocketDidReceiveMessage(webSocket, text: mockStageMessageString)
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // MARK: ForumEventReceiver

    func receive(event: ForumEvent) {
        switch event {
        case let webSocketEvent as WebSocketEvent:
            switch webSocketEvent.type {
            case .Authenticated:
                expectationAuthenticationEvent?.fulfill()
            case .Connected:
                guard let expectationConnectEvent = expectationConnectEvent else {
                    return
                }
                if controller.isSetUp {
                    expectationConnectEvent.fulfill()
                } else {
                    XCTFail("Expected WebSocketController to be connected after the .Connected event has been sent out.")
                }
            case .Disconnected(webSocketError: _):
                guard let expectationDisconnectedEvent = expectationDisconnectedEvent else {
                    return
                }
                if !controller.isSetUp {
                    expectationDisconnectedEvent.fulfill()
                } else {
                    XCTFail("Expected WebSocketController to NOT be connected after the .Disconnect event has been sent out.")
                }
            default:
                XCTFail("Unexpected WebSocketEventType received. Type -> \(webSocketEvent.type)")
            }
        case is ChatMessage:
            expectationIncomingChatMessage?.fulfill()
        case is RefreshStage:
            expectationRefreshStageMessage?.fulfill()
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
    
    init() { super.init(url: NSURL(string: "ws://this.url.is.fake")!) }
    
    override var isConnected: Bool { return _isConnected }
    private var _isConnected: Bool = false
    
    override func connect() {
        _isConnected = true
        delegate?.websocketDidConnect(self)
    }

    override func disconnect(forceTimeout forceTimeout: NSTimeInterval?) {
        _isConnected = false
        delegate?.websocketDidDisconnect(self, error: nil)
    }
    
    override func writeString(str: String, completion: (() -> ())? = nil) {
        if let chatMessageOutboundString = chatMessageOutboundString where chatMessageOutboundString == str {
            expectationOutboundChatMessage?.fulfill()
        } else if let blockUserString = blockUserString where blockUserString == str {
            expectationBlockUserMessage?.fulfill()
        }
    }
}
