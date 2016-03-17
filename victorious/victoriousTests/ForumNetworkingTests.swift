//
//  ForumNetworkingTests.swift
//  victorious
//
//  Created by Patrick Lynch on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ForumNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDefaultReceiver() {
        let parent = MockReceiver()
        
        let event = createEvent()
        parent.receiveEvent(event)
        
        XCTAssertEqual(parent.receivedEvents.count, 1)
        XCTAssertEqual(parent.receivedEvents.first, event)
    }
    
    func testReceiverWithChildren() {
        
        let childA = MockReceiver()
        let childB = MockReceiver()
        let childC = MockReceiver()
        
        let parent = MockReceiverWithChildren(children: [childA, childB, childC])
        let event = createEvent()
        parent.receiveEvent(event)
        
        XCTAssertEqual(childA.receivedEvents.count, 1)
        XCTAssertEqual(childB.receivedEvents.count, 1)
        XCTAssertEqual(childC.receivedEvents.count, 1)
        
        
        XCTAssertEqual(childA.receivedEvents.first, event)
        XCTAssertEqual(childB.receivedEvents.first, event)
        XCTAssertEqual(childC.receivedEvents.first, event)
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
        senderLinkA.sendEvent(event)
        
        XCTAssertEqual(senderDestination.sentEvents.count, 1)
        XCTAssertEqual(senderDestination.sentEvents.first, event)
    }
    
    func createEvent() -> ForumEvent {
        eventIdCounter += 1
        return ForumEvent(
            media: nil,
            messageText: "\(eventIdCounter)",
            date: NSDate()
        )
    }
}

private var eventIdCounter = 0

func ==(lhs: ForumEvent, rhs: ForumEvent) -> Bool {
    return lhs.messageText! == rhs.messageText!
}

extension ForumEvent: Equatable { }

private class MockTerminusSender: ForumEventSender {
    
    var sentEvents = [ForumEvent]()
    
    var nextSender: ForumEventSender?
    
    func sendEvent(event: ForumEvent) {
        sentEvents.append(event)
    }
}

private class MockLinkSender: ForumEventSender {
    
    var nextSender: ForumEventSender?
}

private class MockReceiver: ForumEventReceiver {
    
    var receivedEvents = [ForumEvent]()
    
    func receiveEvent(event: ForumEvent) {
        receivedEvents.append(event)
    }
}

private class MockReceiverWithChildren: ForumEventReceiver {
    
    var children: [ForumEventReceiver]
    
    var childEventReceivers: [ForumEventReceiver] {
        return children
    }
    
    init(children: [ForumEventReceiver] = []) {
        self.children = children
    }
}
