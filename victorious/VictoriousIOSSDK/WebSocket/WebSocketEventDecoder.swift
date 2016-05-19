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
    static let epochTime        = "server_time"
}

protocol WebSocketEventDecoder {
    func decodeEventFromJSON(json: JSON) -> ForumEvent?
}

extension WebSocketEventDecoder {
    
    func decodeEventFromJSON(json: JSON) -> ForumEvent? {
        var forumEvent: ForumEvent?

        if let epochTime = json[Keys.root][Keys.epochTime].double where json[Keys.root].isExists() {
            let serverTime = NSDate(millisecondsSince1970: epochTime)
            
            let chatJson = json[Keys.root][Keys.chat]
            if let chatMessage = ChatMessage(json: chatJson, serverTime: serverTime) {
                forumEvent = chatMessage
            }
            
            let refreshJson = json[Keys.root][Keys.refreshStage]
            if let refresh = RefreshStage(json: refreshJson, serverTime: serverTime) {
                forumEvent = refresh
            }
        }
        
        return forumEvent
    }
}
