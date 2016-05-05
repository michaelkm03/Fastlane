//
//  ForumEventReceiver.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public protocol ForumEvent {
    /// Server time sent as a Unix timestamp in milliseconds.
    var serverTime: NSDate { get }
}

public protocol ForumEventReceiver {
    var childEventReceivers: [ForumEventReceiver] { get }
    func receiveEvent(event: ForumEvent)
}

public extension ForumEventReceiver {
    
    var childEventReceivers: [ForumEventReceiver] {
        return []
    }
    
    func receiveEvent(event: ForumEvent) {
        for receiver in childEventReceivers {
            receiver.receiveEvent(event)
        }
    }
}
