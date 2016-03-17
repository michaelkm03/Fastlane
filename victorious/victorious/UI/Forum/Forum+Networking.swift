//
//  Forum+Networking.swift
//  victorious
//
//  Created by Patrick Lynch on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct ForumEvent {
    let media: MediaAttachment?
    let messageText: String?
    let date: NSDate
}

protocol ForumEventReceiver {
    var childEventReceivers: [ForumEventReceiver] { get }
    func receiveEvent(event: ForumEvent)
}

extension ForumEventReceiver {
    
    var childEventReceivers: [ForumEventReceiver] {
        return []
    }
    
    func receiveEvent(event: ForumEvent) {
        
        // Any objects returned in childEventReceivers by implementations will receive
        // event propgated down
        for receiver in childEventReceivers {
            receiver.receiveEvent(event)
        }
    }
}

protocol ForumEventSender {
    var nextSender: ForumEventSender? { get }
    func sendEvent(event: ForumEvent)
}

extension ForumEventSender {
    
    func sendEvent(event: ForumEvent) {
        
        // Unless defined by a concrete type, default behavior propagates up the event
        nextSender?.sendEvent(event)
    }
}
