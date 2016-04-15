//
//  ChatFeedNetworkDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK
import KVOController

protocol ChatFeedNetworkDataSourceType: VScrollPaginatorDelegate, ForumEventReceiver {
    func startCheckingForNewItems()
    func stopCheckingForNewItems()
}

class ChatFeedNetworkDataSource: NSObject, ChatFeedNetworkDataSourceType {
    
    private let purgeTriggerCount = 20 //< Max count before purge should occur.
    private let purgeTargetCount = 15 //< How many items should remain after purge.
    
    private let eventQueue = ReceivedEventQueue<ChatFeedMessage>()
    
    /// If this interval is too small, the scrolling animations will become choppy
    /// as they step on each other before finishing.
    private var fetchMessageInterval: NSTimeInterval = 1.0
    
    private var timerManager: VTimerManager?
    
    var shouldStashNewContent: Bool = false
    
    // MARK: Initializer and external dependencies
    
    let dependencyManager: VDependencyManager
    let paginatedDataSource: PaginatedDataSource
    
    init( paginatedDataSource: PaginatedDataSource, dependencyManager: VDependencyManager ) {
        self.paginatedDataSource = paginatedDataSource
        self.dependencyManager = dependencyManager
    }
    
    deinit {
        stopCheckingForNewItems()
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        // Pagination not supported in this implementation
    }
    
    func shouldLoadPreviousPage() {
        // Pagination not supported in this implementation
    }
    
    // MARK: - ForumEventReceiver
    
    func receiveEvent(event: ForumEvent) {
        // Stash events in the queue when received and wait to dequeue on our timer cycle
        if let message =  event as? ChatMessage {
            let chatFeedMessage = ChatFeedMessage(source: message)
            eventQueue.addEvent(chatFeedMessage)
        }
    }
    
    // MARK: - ChatFeedNetworkDataSource
    
    func startCheckingForNewItems() {
        guard timerManager == nil else {
            return
        }
        timerManager = VTimerManager.addTimerManagerWithTimeInterval(
            fetchMessageInterval,
            target: self,
            selector: #selector(onTimerTick),
            userInfo: nil,
            repeats: true,
            toRunLoop: NSRunLoop.mainRunLoop(),
            withRunMode: NSRunLoopCommonModes
        )
        dequeueMessages()
    }
    
    func stopCheckingForNewItems() {
        timerManager?.invalidate()
        timerManager = nil
    }
    
    func onTimerTick() {
        if paginatedDataSource.visibleItems.count > purgeTriggerCount {
            // Instead of dequeuing on this tick, we need to purge
            paginatedDataSource.purgeOlderItems(limit: purgeTargetCount)
        } else {
            // Now we can continue dequeuing
            dequeueMessages()
        }
    }
    
    private func dequeueMessages() {
        paginatedDataSource.loadNewItems(
            createOperation: {
                let messages = eventQueue.dequeueAll()
                return DequeueMessagesOperation(messages: messages)
            },
            completion: nil
        )
    }
}

private final class DequeueMessagesOperation: FetcherOperation {
    
    let messages: [ChatFeedMessage]
    
    required init(messages: [ChatFeedMessage]) {
        self.messages = messages
    }
    
    override func main() {
        self.results = messages
    }
}
