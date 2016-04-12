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

        let testConfig = WebSocketConfiguration.init(endPoint: "ws://this.url.is.fake", port: 666, serviceVersion: "v1", forceDisconnectTimeout: 10, appId: "1")!
        webSocket = StubbedWebSocket()
        let testToken = "tok3n"
        controller = WebSocketController(webSocketConfiguration: testConfig, webSocket: webSocket, token: testToken)
        webSocket.delegate = controller

        // A event loop is created so we get messages passed from the controller.
        nextSender = controller
        controller.addChildReceiver(self)
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
        XCTAssertFalse(controller.isConnected, "Expected controller to NOT be connected after initialization.")
        
        expectationConnectEvent = expectationWithDescription("WebSocket-connect-event")
        controller.connect()
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWebSocketDisconnectEvents() {
        webSocket.connect()
        XCTAssertTrue(controller.isConnected, "Expected controller to be connected in order to test out the disconnect event.")

        expectationDisconnectedEvent = expectationWithDescription("WebSocket-disconnect-event")
        controller.disconnect()
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWebSocketInboundChatMessage() {
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
        let chatMessageOutbound = ChatMessageOutbound(timestamp: NSDate(), text: "Test chat message", contentUrl: nil, giphyID: nil)!
        let toServerPackage = JSON(["to_server": chatMessageOutbound.toJSON()])
        webSocket.chatMessageOutboundString = toServerPackage.rawString()
        webSocket.expectationOutboundChatMessage = expectationWithDescription("WebSocket-outgoing-chat-message")
        webSocket.connect()
        
        sendEvent(chatMessageOutbound)
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWebSocketBlockUserMessage() {
        let blockUser = BlockUser(timestamp: NSDate(), userID: "1337")
        let toServerPackage = JSON(["to_server": blockUser.toJSON()])
        webSocket.blockUserString = toServerPackage.rawString()
        webSocket.expectationBlockUserMessage = expectationWithDescription("WebSocket-block-user-message")
        webSocket.connect()

        sendEvent(blockUser)
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testWebSocketRefreshStage() {
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
    
    func receiveEvent(event: ForumEvent) {
        switch event {
        case let webSocketEvent as WebSocketEvent:
            switch webSocketEvent.type {
            case .Authenticated:
                expectationAuthenticationEvent?.fulfill()
            case .Connected:
                guard let expectationConnectEvent = expectationConnectEvent else {
                    return
                }
                if controller.isConnected {
                    expectationConnectEvent.fulfill()
                } else {
                    XCTFail("Expected WebSocketController to be connected after the .Connected event has been sent out.")
                }
            case .Disconnected(webSocketError: _):
                guard let expectationDisconnectedEvent = expectationDisconnectedEvent else {
                    return
                }
                if !controller.isConnected {
                    expectationDisconnectedEvent.fulfill()
                } else {
                    XCTFail("Expected WebSocketController to NOT be connected after the .Disconnect event has been sent out.")
                }
            default:
                XCTFail("Unexpected WebSocketEventType received. Type -> \(webSocketEvent.type)")
            }
        case is ChatMessageInbound:
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
    var blockUserString: String?
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
