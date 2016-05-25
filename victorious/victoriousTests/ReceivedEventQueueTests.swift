//
//  ReceivedEventQueueTests.swift
//  victorious
//
//  Created by Patrick Lynch on 4/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ReceivedEventQueueTests: XCTestCase {

    var queue: ReceivedEventQueue<ChatFeedMessage>!
    let eventCount = 30
    let maximimEventCount = 20
    let user = User(id: 897, name: "Mr. User", previewImages: [ImageAsset(url: NSURL(string: "http://google.com")!)])
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAdd() {
        queue = ReceivedEventQueue<ChatFeedMessage>()
        
        for i in 0..<eventCount {
            let content = Content(releasedAt: NSDate(), text: "\(i)", author: user)
            queue.addEvent(ChatFeedMessage(content: content, displayOrder: i))
            XCTAssertEqual(queue.count, i+1)
        }
        
        let dequeuedEvents = queue.dequeueAll()
        XCTAssertEqual(queue.count, 0)
        XCTAssertEqual(dequeuedEvents.count, eventCount)
        XCTAssert(queue.isEmpty)
    }
    
    func testAddWithinMaximum() {
        queue = ReceivedEventQueue(maximimEventCount: maximimEventCount)
        
        for i in 0..<eventCount {
            let content = Content(releasedAt: NSDate(), text: "\(i)", author: user)
            queue.addEvent(ChatFeedMessage(content: content, displayOrder: i))
            XCTAssertEqual(queue.count, min(i+1, maximimEventCount))
        }
        
        let dequeuedEvents = queue.dequeueAll()
        XCTAssertEqual(queue.count, 0)
        XCTAssertEqual(dequeuedEvents.count, maximimEventCount)
        XCTAssert(queue.isEmpty)
    }
    
    func testDequeueAll() {
        queue = ReceivedEventQueue()
        
        for i in 0..<eventCount {
            let content = Content(releasedAt: NSDate(), text: "\(i)", author: user)
            queue.addEvent(ChatFeedMessage(content: content, displayOrder: i))
        }
        
        let dequeuedEvents = queue.dequeueAll()
        
        XCTAssertEqual(queue.count, 0)
        XCTAssert(queue.isEmpty)
        XCTAssertEqual(dequeuedEvents.first?.content.text, "\(0)")
        XCTAssertEqual(dequeuedEvents.last?.content.text, "\(eventCount-1)")
        XCTAssertEqual(dequeuedEvents.count, eventCount)
    }
    
    func testDequeueCount() {
        queue = ReceivedEventQueue()
        
        for i in 0..<eventCount {
            let content = Content(releasedAt: NSDate(), text: "\(i)", author: user)
            queue.addEvent(ChatFeedMessage(content: content, displayOrder: i))
        }
        
        let dequeCount = 10
        let dequeuedEvents = queue.dequeue(count: dequeCount)
        
        XCTAssertEqual(queue.count, eventCount - dequeCount)
        XCTAssertEqual(dequeuedEvents.count, dequeCount)
        XCTAssertEqual(dequeuedEvents.first?.content.text, "\(0)")
        XCTAssertEqual(dequeuedEvents.last?.content.text, "\(dequeuedEvents.count-1)")
        XCTAssertFalse(queue.isEmpty)
    }
    
    func testDequeueOverCount() {
        queue = ReceivedEventQueue()
        
        for i in 0..<eventCount {
            let content = Content(releasedAt: NSDate(), text: "\(i)", author: user)
            queue.addEvent(ChatFeedMessage(content: content, displayOrder: i))
        }
        
        let dequeCount = 40
        let dequeuedEvents = queue.dequeue(count: dequeCount)
        
        XCTAssertEqual(queue.count, 0)
        XCTAssert(queue.isEmpty)
        XCTAssertEqual(dequeuedEvents.first?.content.text, "\(0)")
        XCTAssertEqual(dequeuedEvents.last?.content.text, "\(eventCount-1)")
        XCTAssertEqual(dequeuedEvents.count, eventCount)
    }
}
