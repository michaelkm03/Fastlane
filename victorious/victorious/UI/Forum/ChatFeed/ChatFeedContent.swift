//
//  ChatFeedContent.swift
//  victorious
//
//  Created by Jarod Long on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A wrapper around a `ContentModel` that contains extra information specific to the chat feed.
class ChatFeedContent {
    /// The content model.
    let content: ContentModel
    
    /// The calculated size of the content's `ChatFeedMessageCell`, which we cache for performance.
    ///
    /// If nil, the size has not been calculated yet.
    ///
    var size: CGSize?
    
    /// The state of the content while it's being created by the current user.
    ///
    /// This should be nil if this is not content that is actively being created by the user.
    ///
    var creationState: ContentCreationState?
    
    init(_ content: ContentModel, creationState: ContentCreationState? = nil) {
        self.content = content
        self.creationState = creationState
    }
}
