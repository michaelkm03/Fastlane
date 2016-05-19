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

public protocol ForumEventReceiver: class {
    var childEventReceivers: [ForumEventReceiver] { get }
    func receive(event: ForumEvent)
}

public extension ForumEventReceiver {
    
    var childEventReceivers: [ForumEventReceiver] {
        return []
    }
    
    func broadcast(event: ForumEvent) {
        for receiver in childEventReceivers {
            receiver.receive(event)
        }
        
        for receiver in childEventReceivers {
            receiver.broadcast(event)
        }
    }
}
