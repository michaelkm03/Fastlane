//
//  ReceivedEventQueue.swift
//  victorious
//
//  Created by Patrick Lynch on 3/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ReceivedEventQueue<EventType> {
    
    let maximimEventCount: Int?
    
    init(maximimEventCount: Int? = nil) {
        self.maximimEventCount = maximimEventCount
    }
    
    var count: Int {
        return events.count
    }
    
    var isEmpty: Bool {
        return events.isEmpty
    }
    
    private var events = [EventType]()
    
    func addEvent(event: EventType) {
        if let max = maximimEventCount where events.count >= max {
            events.removeFirst()
        }
        events.append(event)
    }
    
    func dequeue(count count: Int) -> [EventType] {
        guard count <= events.count else {
            return dequeueAll()
        }
        let output = events[0..<count]
        events.removeRange(0..<count)
        return Array(output)
    }
    
    func dequeueAll() -> [EventType] {
        let output = events
        events = []
        return output
    }
}
