//
//  ForumEvent.swift
//  victoriousIOSSDK
//
//  Created by Jarod Long on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// An event that can be broadcast in the forum event chain.
public enum ForumEvent {
    /// Notifies that content has arrived with the given loading type.
    case handleContent([Content], PaginatedLoadingType)
    
    /// Requests loading of older content in the chat feed.
    case loadOldContent
    
    /// Sends content created by the user.
    case sendContent(Content)
    
    /// Notifies the chat UI that new messages are being loaded or have finished loading with the given loading type,
    /// indicating that a loading state should be shown or hidden.
    case setLoadingContent(Bool, PaginatedLoadingType)
    
    /// Notifies that a filter has been applied to the chat feed using the given API path. A nil value indicates that
    /// no filter is being applied.
    case filterContent(path: APIPath?)
    
    /// Requests that the given content is shown in the caption bar
    case showCaptionContent(Content)
    
    /// Notifies of the given websocket event.
    case websocket(WebSocketEvent)
    
    /// Requests that the stage is refreshed with new content.
    case refreshStage(RefreshStage)
    
    /// A creator responded to a fan's question with an answer.
    case creatorQuestionResponse(CreatorQuestionResponse)
    
    /// Closes either the main or VIP stage.
    case closeStage(StageSection)

    /// Closes the whole VIP experience.
    case closeVIP()
    
    /// Requests that the given user is blocked.
    case blockUser(BlockUser)

    /// Indicates the current count of chat users.
    case chatUserCount(ChatUserCount)
    
    /// Enables or disables optimistic posting for different forums
    case setOptimisticPostingEnabled(Bool)
    
    /// Enables or disables the chat feed activity indicator for different forums.
    case setChatActivityIndicatorEnabled(Bool)

    /// Notifies when the active feed changed
    case activeFeedChanged
}
