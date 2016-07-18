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
    case appendContent([ContentModel])
    
    /// Requests that the given content is prepended to the chat feed.
    case prependContent([ContentModel])
    
    /// Requests that the current chat feed content is replaced with the given content.
    case replaceContent([ContentModel])
    
    /// Requests loading of older content in the chat feed.
    case loadOldContent
    
    /// Sends content created by the user.
    case sendContent(ContentModel)
    
    /// Notifies that a filter has been applied to the chat feed using the given API path. A nil value indicates that
    /// no filter is being applied.
    case filterContent(path: APIPath?)
    
    /// Requests that the given content is shown in the caption bar
    case showCaptionContent(ContentModel)
    
    /// Notifies of the given websocket event.
    case websocket(WebSocketEvent)
    
    /// Requests that the stage is refreshed with new content.
    case refreshStage(RefreshStage)
    
    /// Closes the main stage
    case closeMainStage
    
    /// Requests that the given user is blocked.
    case blockUser(BlockUser)

    /// Indicates the current count of chat users.
    case chatUserCount(ChatUserCount)
}
