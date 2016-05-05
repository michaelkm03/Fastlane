//
//  WebSocketEvent.swift
//  victorious
//
//  Created by Sebastian Nystorm on 24/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  The container for WebSocket related messages.
 */
public struct WebSocketEvent: ForumEvent {
    // MARK: ForumEvent
    public let serverTime: NSDate
    
    public let type: WebSocketEventType
    
    public init(type: WebSocketEventType, serverTime: NSDate = NSDate()) {
        self.type = type
        self.serverTime = serverTime
    }
}
