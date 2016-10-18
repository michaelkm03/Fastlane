//
//  ForumEventReceiver.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

public protocol ForumEventReceiver: class {
    var childEventReceivers: [ForumEventReceiver] { get }
    func receive(_ event: ForumEvent)
}

public extension ForumEventReceiver {
    func broadcast(_ event: ForumEvent) {
        for receiver in childEventReceivers {
            receiver.receive(event)
        }
        
        for receiver in childEventReceivers {
            receiver.broadcast(event)
        }
    }
}
