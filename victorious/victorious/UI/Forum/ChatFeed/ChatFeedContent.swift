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
    
    init?(content: Content, width: CGFloat, dependencyManager: VDependencyManager, creationState: ContentCreationState? = nil) {
        guard let height = ChatFeedMessageCell.cellHeight(displaying: content, inWidth: width, dependencyManager: dependencyManager) else {
            return nil
        }
        self.content = content
        self.size = CGSize(width: width, height: height)
        self.creationState = creationState
    }
}
