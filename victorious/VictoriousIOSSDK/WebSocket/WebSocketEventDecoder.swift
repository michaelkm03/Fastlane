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
    static let creatorAnswer        = "creator_answer"
    static let serverTime           = "server_time"
    static let type                 = "type"
    static let error                = "error"
}

/// The different types of web socket messages we can get from the backend
private struct Types {
    /// A new piece of chat message to be displayed in the chat feed
    static let chatMessage          = "CHAT"
    /// A new piece of content to be displayed on the stage
    static let stageRefresh         = "REFRESH"
    /// A creator answer sent by the creator to answer a fan's question during an AMA(Ask Me Anything) event.
    /// The question will be displayed in a toast, and the creator's response goes to the stage.
    /// - note: Video response will not be synced.
    static let amaCreatorAnswer     = "CREATOR_ANSWER"
    /// An update to the total number of users chatting right now
    static let chatUserCount        = "CHAT_USERS"
}

// !!! BEWARE DRAGONS BELOW !!!
// This is an extreme h4ck that I had to implement in order to have this functionality in place at all. :/
// Please remove as soon as we get a proper solution in place. And for the record, yes I hate myself for writing this.
//
// If we get back a stage refresh message with a custom content id (specified below) we are to treat it as a close stage message.
//
private struct SocketClose {
    static let contentIdKey         = "content_id"
    static let magicKey             = "close socket"
}

protocol WebSocketEventDecoder {
    /// Parses out a ForumEvent from the JSON string coming in over the WebSocket.
    func decodeEvent(from json: JSON) -> ForumEvent?

    /// `WebSocketError` is handled uniquely since it does not follow the layout as the other messages. 
    /// In theory we could get an error message without the connection being closed, use `didDisconnect` to specify this.
    func decodeError(from json: JSON, didDisconnect: Bool) -> ForumEvent?
}

extension WebSocketEventDecoder {
    /// Returns a *single* ForumEvent from the JSON blob passed in if parsing succeeds.
    /// - NOTE: Don't pass in a JSON blob with multiple events, there is no guarantee which one will be returned.
    func decodeEvent(from json: JSON) -> ForumEvent? {
        var forumEvent: ForumEvent?
        let rootNode = json[Keys.root]
        
        guard
            let serverTime = Timestamp(apiString: rootNode[Keys.serverTime].stringValue), rootNode.exists(),
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
                
                if content.author?.accessLevel.isCreator == true {
                    forumEvent = .showCaptionContent(content)
                }
                else {
                    forumEvent = .handleContent([content], .newer)
                }
            case Types.stageRefresh:
                let refreshJSON = rootNode[Keys.refreshStage]
                if refreshJSON[SocketClose.contentIdKey].string == SocketClose.magicKey {
                    forumEvent = .closeVIP()
                }
                else if let refresh = RefreshStage(json: refreshJSON, serverTime: serverTime) {
                    forumEvent = .refreshStage(refresh)
                }
            case Types.amaCreatorAnswer:
                let answerJSON = rootNode[Keys.creatorAnswer]
                if let creatorAnswer = CreatorAnswer(json: answerJSON) {
                    forumEvent = .creatorRespondedToQuestion(creatorAnswer)
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

    func decodeError(from json: JSON, didDisconnect: Bool = false) -> ForumEvent? {
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
