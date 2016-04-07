//
//  ForumEventSender.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public protocol ForumEventSender {
    var nextSender: ForumEventSender? { get }
    func sendEvent(event: ForumEvent)
}

public extension ForumEventSender {
    
    func sendEvent(event: ForumEvent) {
        // Unless defined by a concrete type, the default behavior passes the message along.
        nextSender?.sendEvent(event)
    }
}
