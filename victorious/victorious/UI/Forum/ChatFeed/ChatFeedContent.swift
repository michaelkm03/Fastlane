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
    var size: CGSize
    
    private init(_ content: ContentModel, size: CGSize) {
        self.content = content
        self.size = size
    }
    
    static func createChatFeedContent(fromContentModel content: ContentModel, withWidth width: CGFloat, dependencyManager: VDependencyManager) -> ChatFeedContent? {
        guard let height = ChatFeedMessageCell.cellHeight(displaying: content, inWidth: width, dependencyManager: dependencyManager) else {
            return nil
        }
        return ChatFeedContent(content, size: CGSize(width: width, height: height))
    }
}
