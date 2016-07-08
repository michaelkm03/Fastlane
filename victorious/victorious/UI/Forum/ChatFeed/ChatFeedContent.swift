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
    
    init(_ content: ContentModel) {
        self.content = content
    }
}
