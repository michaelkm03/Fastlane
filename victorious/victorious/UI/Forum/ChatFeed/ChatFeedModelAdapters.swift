//
//  ChatFeedModelAdapters.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// A reference type adaptor for `ContentModel`.
class ChatFeedMessage: NSObject, PaginatedObjectType {
    // MARK: - Initializing
    
    init(content: ContentModel, displayOrder: NSNumber) {
        self.content = content
        self.displayOrder = displayOrder
    }
    
    // MARK: - Data
    
    let content: ContentModel
    var displayOrder: NSNumber
}
