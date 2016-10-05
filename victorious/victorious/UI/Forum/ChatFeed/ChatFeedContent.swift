//
//  ChatFeedContent.swift
//  victorious
//
//  Created by Jarod Long on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// A wrapper around a `Content` that contains extra information specific to the chat feed.
struct ChatFeedContent {
    /// The content model.
    var content: Content
    
    /// The calculated size of the content's `ChatFeedMessageCell`, which we cache for performance.
    var size: CGSize
    
    /// The state of the content while it's being created by the current user.
    ///
    /// This should be nil if this is not content that is actively being created by the user.
    ///
    var creationState: ContentCreationState?
    
    /// The ID of the chat room that this content is being posted to, or nil if the content is being posted to the main
    /// feed.
    ///
    /// This will also be nil if this is not content that is actively being created by the user.
    ///
    var pendingChatRoomID: ChatRoom.ID?
    
    init?(content: Content, width: CGFloat, dependencyManager: VDependencyManager, creationState: ContentCreationState? = nil, pendingChatRoomID: ChatRoom.ID? = nil) {
        guard let height = ChatFeedMessageCell.cellHeight(displaying: content, inWidth: width, dependencyManager: dependencyManager) else {
            return nil
        }
        
        self.content = content
        self.size = CGSize(width: width, height: height)
        self.creationState = creationState
        self.pendingChatRoomID = pendingChatRoomID
    }
}
