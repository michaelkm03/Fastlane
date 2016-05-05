//
//  ChatFeedModelAdapters.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// A reference type adaptor for value type `VictoriousIOSSDK.ChatMessage`.
class ChatFeedMessage: NSObject, PaginatedObjectType {
    
    var displayOrder: NSNumber
    
    private let source: ChatMessage
    
    var sender: ChatMessageUser {
        return source.fromUser
    }
    
    let mediaAttachment: MediaAttachment?
    
    init(displayOrder: NSNumber, source: ChatMessage) {
        self.source = source
        self.displayOrder = displayOrder
        self.mediaAttachment = source.mediaAttachment
    }
    
    var timeLabel: String {
        return source.serverTime.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
    }
    
    var text: String? {
        return source.text
    }
}
