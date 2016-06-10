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
    static let epochTime            = "server_time"
    static let type                 = "type"
}

private struct Types {
    static let chatMessage          = "CHAT"
    static let stageRefresh         = "REFRESH"
    static let chatUserCount        = "CHAT_USERS"
}

protocol WebSocketEventDecoder {
    func decodeEventFromJSON(json: JSON) -> ForumEvent?
}

extension WebSocketEventDecoder {
    
    func decodeEventFromJSON(json: JSON) -> ForumEvent? {
        var forumEvent: ForumEvent?

        let rootNode = json[Keys.root]
        if let epochTime = rootNode[Keys.epochTime].double where rootNode.isExists() {

            guard let type = rootNode[Keys.type].string else {
                return nil
            }

            let serverTime = NSDate(millisecondsSince1970: epochTime)

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
                print("Unparsable WebSocket message returned -> \(rootNode.stringValue)")
            }
        }
        
        return forumEvent
    }
}
