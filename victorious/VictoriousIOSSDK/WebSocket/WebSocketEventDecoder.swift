//
//  WebSocketEventDecoder.swift
//  victorious
//
//  Created by Sebastian Nystorm on 22/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private struct Keys {
    static let root             = "to_client"
    static let chat             = "chat"
    static let refreshStage     = "refresh"
    static let epochTime        = "epoch_time"
}

protocol WebSocketEventDecoder {
    func decodeEventsFromJson(jon: JSON) -> [ForumEvent]
}

extension WebSocketEventDecoder {
    
    func decodeEventsFromJson(json: JSON) -> [ForumEvent] {
        var messages: [ForumEvent] = []
        
        if let epochTime = json[Keys.root][Keys.epochTime].double where json[Keys.root].isExists() {
            let timestamp = NSDate(timeIntervalSince1970: epochTime)
            
            let chatJson = json[Keys.root][Keys.chat]
            if let chatMessage = ChatMessage(json: chatJson, timestamp: timestamp) {
                messages.append(chatMessage)
            }
            
            let refreshJson = json[Keys.root][Keys.refreshStage]
            if let refresh = RefreshStage(json: refreshJson, timestamp: timestamp) {
                messages.append(refresh)
            }
        }
        return messages
    }
}