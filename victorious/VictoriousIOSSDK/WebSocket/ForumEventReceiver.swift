//
//  ForumEventReceiver.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

public protocol ForumEventReceiver: class {
    var childEventReceivers: [ForumEventReceiver] { get }
    func receive(event: ForumEvent)
}

public extension ForumEventReceiver {
    
    var childEventReceivers: [ForumEventReceiver] {
        return []
    }
    
    func receive(_ event: ForumEvent) {}
    
    func broadcast(_ event: ForumEvent) {
        for receiver in childEventReceivers {
            receiver.receive(event)
        }
        
        for receiver in childEventReceivers {
            receiver.broadcast(event)
        }
    }
}
