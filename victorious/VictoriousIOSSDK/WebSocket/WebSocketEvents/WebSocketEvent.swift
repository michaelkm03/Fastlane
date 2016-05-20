//
//  WebSocketEvent.swift
//  victorious
//
//  Created by Sebastian Nystorm on 24/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

///
/// The container for WebSocket related messages.
///
public struct WebSocketEvent: ForumEvent, CustomStringConvertible {

    // MARK: ForumEvent

    public let serverTime: NSDate
    
    public let type: WebSocketEventType

    // MARK: CustomStringConvertible

    public var description: String {
        return "WSEvent type: \(type) serverTime: \(serverTime)"
    }
    
    public init(type: WebSocketEventType, serverTime: NSDate = NSDate()) {
        self.type = type
        self.serverTime = serverTime
    }
}
