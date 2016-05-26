//
//  ForumEventSender.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that as node in a ForumEvent tree can propagate messages
/// up stream, i.e. from leaf to root.
public protocol ForumEventSender: class {
    
    /// Events can be propagated up to the next sender (chain of responsibility)
    weak var nextSender: ForumEventSender? { get }
    
    func send(event: ForumEvent)
}

public extension ForumEventSender {
    func send(event: ForumEvent) {
        // Unless defined by a concrete type, the default behavior passes the event along.
        nextSender?.send(event)
    }
}
