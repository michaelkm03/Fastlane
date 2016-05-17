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
class ChatFeedMessage: NSObject, ChatMessageType, PaginatedObjectType {
    
    private let source: ChatMessage
    
    init(displayOrder: NSNumber, source: ChatMessage) {
        self.source = source
        self.displayOrder = displayOrder
        self.mediaAttachment = source.mediaAttachment
    }
    
    // MARK: - ChatMessageType
    
    var displayOrder: NSNumber
    
    let mediaAttachment: MediaAttachment?
    
    var dateSent: NSDate {
        return source.serverTime
    }
    var text: String? {
        return source.text
    }
    
    var userID: Int {
        return source.fromUser.id
    }
    
    var username: String {
        return source.fromUser.name
    }
    
    var profileURL: NSURL {
        return source.fromUser.profileURL ?? NSURL(string: "")!
    }
    
    var timeLabel: String {
        return source.serverTime.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
    }
}
