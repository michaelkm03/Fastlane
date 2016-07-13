//
//  ChatFeedContent.swift
//  victorious
//
//  Created by Jarod Long on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A wrapper around a `ContentModel` that contains extra information specific to the chat feed.
struct ChatFeedContent {
    /// The content model.
    var content: ContentModel
    
    /// The calculated size of the content's `ChatFeedMessageCell`, which we cache for performance.
    var size: CGSize
    
    init?(content: ContentModel, width: CGFloat, dependencyManager: VDependencyManager) {
        guard let height = ChatFeedMessageCell.cellHeight(displaying: content, inWidth: width, dependencyManager: dependencyManager) else {
            return nil
        }
        self.content = content
        self.size = CGSize(width: width, height: height)
    }
}
