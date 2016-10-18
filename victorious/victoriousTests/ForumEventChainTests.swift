//
//  ForumEventChainTests.swift
//  victorious
//
//  Created by Patrick Lynch on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ForumEventChainTests: XCTestCase {
    
    func testDefaultReceiver() {
        let parent = MockReceiver()
        
        let event = createEvent()
        parent.receive(event)
        
        XCTAssertEqual(parent.receivedEvents.count, 1)
    }
    
    func testReceiverWithChildren() {
        let childA = MockReceiver()
        let childB = MockReceiver()
        let childC = MockReceiver()
        
        let parent = MockReceiverWithChildren(children: [childA, childB, childC])
        let event = createEvent()
        parent.broadcast(event)
        
        XCTAssertEqual(childA.receivedEvents.count, 1)
        XCTAssertEqual(childB.receivedEvents.count, 1)
        XCTAssertEqual(childC.receivedEvents.count, 1)
    }
    
    func testDefaultSender() {
        let senderLinkA = MockLinkSender()
        let senderLinkB = MockLinkSender()
        let senderLinkC = MockLinkSender()
        let senderDestination = MockTerminusSender()
        
        senderLinkA.nextSender = senderLinkB
        senderLinkB.nextSender = senderLinkC
        senderLinkC.nextSender = senderDestination
        
        let event = createEvent()
        senderLinkA.send(event)
        
        XCTAssertEqual(senderDestination.sentEvents.count, 1)
    }
    
    func createEvent() -> ForumEvent {
        return .websocket(.connected)
    }
    
    func testPerformance() {
        let childA = MockReceiver()
        let childB = MockReceiver()
        let childC = MockReceiver()
        
        let parent = MockReceiverWithChildren(children: [childA, childB, childC])
        let origin = MockReceiverWithChildren(children: [parent])
        
        self.measure() {
            for _ in 1...10000 {
                let event = self.createEvent()
                origin.receive(event)
            }
        }
    }
}

private class MockTerminusSender: ForumEventSender {
    var sentEvents = [ForumEvent]()
    
    var nextSender: ForumEventSender?
    
    func send(_ event: ForumEvent) {
        sentEvents.append(event)
    }
}

private class MockLinkSender: ForumEventSender {
    var nextSender: ForumEventSender?
}

private class MockReceiver: ForumEventReceiver {
    var childEventReceivers = [ForumEventReceiver]()

    var receivedEvents = [ForumEvent]()
    
    func receive(_ event: ForumEvent) {
        receivedEvents.append(event)
    }
}

private class MockReceiverWithChildren: ForumEventReceiver {
    var children: [ForumEventReceiver]
    
    var childEventReceivers: [ForumEventReceiver] {
        return children
    }
    
    private func receive(_ event: ForumEvent) {}
    
    init(children: [ForumEventReceiver] = []) {
        self.children = children
    }
}
