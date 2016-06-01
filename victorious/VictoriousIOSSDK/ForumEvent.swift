//
//  ForumEvent.swift
//  victoriousIOSSDK
//
//  Created by Jarod Long on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// An event that can be broadcast in the forum event chain.
public enum ForumEvent {
    /// Requests that the given content is appended to the chat feed.
    case appendContent([Content])
    
    /// Notifies of the given websocket event.
    case websocket(WebSocketEvent)
    
    /// Requests that the stage is refreshed with new content.
    case refreshStage(RefreshStage)
    
    /// Requests that the given user is blocked.
    case blockUser(BlockUser)
    
    /// Sends content created by the user.
    case sendContent(Content)
    
    /// Requests loading of older content in the chat feed.
    case loadOldContent
}
