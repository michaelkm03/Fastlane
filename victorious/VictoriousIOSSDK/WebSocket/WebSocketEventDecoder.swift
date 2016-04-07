//
//  WebSocketEventDecoder.swift
//  victorious
//
//  Created by Sebastian Nystorm on 22/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private struct WebSocketEventKeys {
    static let rootKey = "to_client"
    static let chatKey = "chat"
    static let refreshStageKey = "refresh"
    static let epochTimeKey = "epoch_time"
}

protocol WebSocketEventDecoder {
    func decodeEventsFromJson(jon: JSON) -> [ForumEvent]
}

extension WebSocketEventDecoder {
    
    func decodeEventsFromJson(json: JSON) -> [ForumEvent] {
        var messages: [ForumEvent] = []
        
        if let epochTime = json[WebSocketEventKeys.rootKey][WebSocketEventKeys.epochTimeKey].double where json[WebSocketEventKeys.rootKey].isExists() {
            let timestamp = NSDate(timeIntervalSince1970: epochTime)
            
            let chatJson = json[WebSocketEventKeys.rootKey][WebSocketEventKeys.chatKey]
            if let chatMessage = ChatMessageInbound(json: chatJson, timestamp: timestamp) {
                messages.append(chatMessage)
            }
            
            let refreshJson = json[WebSocketEventKeys.rootKey][WebSocketEventKeys.refreshStageKey]
            if let refresh = RefreshStage(json: refreshJson, timestamp: timestamp) {
                messages.append(refresh)
            }
        }
        return messages
    }
}
