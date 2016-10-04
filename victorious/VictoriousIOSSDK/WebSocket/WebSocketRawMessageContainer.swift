//
//  WebSocketRawMessageContainer.swift
//  victorious
//
//  Created by Sebastian Nystorm on 17/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct WebSocketRawMessage {
    public let messageString: String
    public let creationDate: NSDate
    public var json: JSON?

    public init (messageString: String, json: JSON? = nil) {
        self.messageString = messageString
        creationDate = NSDate()
        self.json = json
    }
}

public class WebSocketRawMessageContainer {

    /// The visual divider in the string log between all messages.
    private let messageTextDivider = "\n\n-----------------------\n\n"

    /// The container which contains all of the message send and received over the WebSocket.
    public private(set) var messageContainer: [WebSocketRawMessage] = []

    /// Will add the message to a container IF the app is build with a custom flag: `V_ENABLE_WEBSOCKET_DEBUG_MENU`
    public func add(_ message: WebSocketRawMessage) {
        #if V_ENABLE_WEBSOCKET_DEBUG_MENU
            messageContainer.append(message)
        #endif
    }

    /// Will clear the message container.
    public func clearMessages() {
        messageContainer = []
    }

    /// Will return a String will all the raw messages concatinated in order.
    /// - NOTE: This might be a huge string, be careful of when you call on this function.
    public func exportAllMessages() -> String {
        let allMessagesString = messageContainer.reduce("") {
            let message = ("\nCreation date: \($1.creationDate)\n" + $1.messageString + messageTextDivider)
            return $0 + message
        }

        return allMessagesString
    }

    /// Number of raw messages in the queue.
    public var messageCount: Int {
        return messageContainer.count
    }
}
