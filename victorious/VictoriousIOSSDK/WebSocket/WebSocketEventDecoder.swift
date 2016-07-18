//
//  WebSocketEventDecoder.swift
//  victorious
//
//  Created by Sebastian Nystorm on 22/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private struct Keys {
    static let root                 = "to_client"
    static let chat                 = "chat"
    static let refreshStage         = "refresh"
    static let serverTime           = "server_time"
    static let type                 = "type"
    static let error                = "error"
}

private struct Types {
    static let chatMessage          = "CHAT"
    static let stageRefresh         = "REFRESH"
    static let chatUserCount        = "CHAT_USERS"
}

protocol WebSocketEventDecoder {
    /// Parses out a ForumEvent from the JSON string coming in over the WebSocket.
    func decodeEventFromJSON(json: JSON) -> ForumEvent?

    /// `WebSocketError` is handled uniquely since it does not follow the layout as the other messages. 
    /// In theory we could get an error message without the connection being closed, use `didDisconnect` to specify this.
    func decodeErrorFromJSON(json: JSON, didDisconnect: Bool) -> ForumEvent?
}

extension WebSocketEventDecoder {
    
    func decodeEventFromJSON(json: JSON) -> ForumEvent? {
        var forumEvent: ForumEvent?

        let rootNode = json[Keys.root]
        if let serverTime = rootNode[Keys.serverTime].double where rootNode.isExists() {

            guard let type = rootNode[Keys.type].string else {
                return nil
            }

            let serverTime = NSDate(millisecondsSince1970: serverTime)

            switch type {
                case Types.chatMessage:
                    let chatJSON = json[Keys.root][Keys.chat]
                    if let content = Content(chatMessageJSON: chatJSON, serverTime: serverTime) {
                        forumEvent = .appendContent([content])
                    }
                case Types.stageRefresh:
                    let refreshJSON = rootNode[Keys.refreshStage]
                    if let refresh = RefreshStage(json: refreshJSON, serverTime: serverTime) {
                        forumEvent = .refreshStage(refresh)
                    }
                case Types.chatUserCount:
                    if let chatUserCount = ChatUserCount(json: json[Keys.root], serverTime: serverTime) {
                        forumEvent = .chatUserCount(chatUserCount)
                    }
                default:
                    forumEvent = nil
            }
        }
        
        return forumEvent
    }

    func decodeErrorFromJSON(json: JSON, didDisconnect: Bool = false) -> ForumEvent? {
        var webSocketEvent: ForumEvent?

        if let webSocketError = WebSocketError(json: json[Keys.root][Keys.error], didDisconnect: didDisconnect) {
            if didDisconnect {
                webSocketEvent = .websocket(.disconnected(webSocketError: webSocketError))
            } else {
                webSocketEvent = .websocket(.serverError(webSocketError: webSocketError))
            }
        }

        return webSocketEvent
    }
}
