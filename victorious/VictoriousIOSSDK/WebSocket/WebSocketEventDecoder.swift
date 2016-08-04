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

// !!! BEWARE DRAGONS BELOW !!!
// This is an extreme h4ck that I had to implement in order to have this functionality in place at all. :/
// Please remove as soon as we get a proper solution in place. And for the record, yes I hate myself for writing this.
//
// If we get back a stage refresh message with a custom content id (specified below) we are to treat it as a close stage message.
//
private struct StageClose {
    static let contentIdKey         = "content_id"
    static let magicKey             = "close socket"
}

protocol WebSocketEventDecoder {
    /// Parses out a ForumEvent from the JSON string coming in over the WebSocket.
    func decodeEventFromJSON(json: JSON) -> ForumEvent?

    /// `WebSocketError` is handled uniquely since it does not follow the layout as the other messages. 
    /// In theory we could get an error message without the connection being closed, use `didDisconnect` to specify this.
    func decodeErrorFromJSON(json: JSON, didDisconnect: Bool) -> ForumEvent?
}

extension WebSocketEventDecoder {
    /// Returns a *single* ForumEvent from the JSON blob passed in if parsing succeeds.
    /// - NOTE: Don't pass in a JSON blob with multiple events, there is no guarantee which one will be returned.
    func decodeEventFromJSON(json: JSON) -> ForumEvent? {
        var forumEvent: ForumEvent?
        let rootNode = json[Keys.root]
        
        guard
            let serverTime = Timestamp(apiString: rootNode[Keys.serverTime].stringValue) where rootNode.isExists(),
            let type = rootNode[Keys.type].string
        else {
            return nil
        }
        
        switch type {
            case Types.chatMessage:
                let chatJSON = json[Keys.root][Keys.chat]
                guard let content = Content(chatMessageJSON: chatJSON, serverTime: serverTime) else {
                    return nil
                }
                
                if content.author.accessLevel.isCreator {
                    forumEvent = .showCaptionContent(content)
                }
                else {
                    forumEvent = .handleContent([content], .newer)
                }
            case Types.stageRefresh:
                let refreshJSON = rootNode[Keys.refreshStage]
                if refreshJSON[StageClose.contentIdKey].string == StageClose.magicKey {
                    forumEvent = .closeStage(.vip)
                }
                else if let refresh = RefreshStage(json: refreshJSON, serverTime: serverTime) {
                    forumEvent = .refreshStage(refresh)
                }
            case Types.chatUserCount:
                if let chatUserCount = ChatUserCount(json: json[Keys.root], serverTime: serverTime) {
                    forumEvent = .chatUserCount(chatUserCount)
                }
            default:
                forumEvent = nil
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
