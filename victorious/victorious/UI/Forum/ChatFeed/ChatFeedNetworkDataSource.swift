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
    
    private let eventQueue = ReceivedEventQueue<ChatFeedMessage>()
    
    /// If this interval is too small, the scrolling animations will become choppy
    /// as they step on each other before finishing.
    private var fetchMessageInterval: NSTimeInterval = 1.0
    
    private var timerManager: VTimerManager?
    
    var shouldStashNewContent: Bool = false
    
    private var eventCounter = Int.max
    
    // MARK: Initializer and external dependencies
    
    let dependencyManager: VDependencyManager
    let paginatedDataSource: PaginatedDataSource
    
    init( paginatedDataSource: PaginatedDataSource, dependencyManager: VDependencyManager ) {
        self.paginatedDataSource = paginatedDataSource
        self.dependencyManager = dependencyManager
        super.init()
        
        self.paginatedDataSource.sortOrder = .OrderedDescending
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
    
    func receive(event: ForumEvent) {
        // Stash events in the queue when received and wait to dequeue on our timer cycle
        if let message =  event as? ChatMessage {
            let chatFeedMessage = ChatFeedMessage(displayOrder: eventCounter, source: message)
            eventQueue.addEvent(chatFeedMessage)
            eventCounter -= 1
            
            // Deuque messages right away if from the current user so FetcherOperation
            // So that the sending feels responsive and nothing gets out of order
            if chatFeedMessage.userID == VCurrentUser.user()?.remoteId?.integerValue {
                dequeueMessages()
            }
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
        if paginatedDataSource.visibleItems.count > dependencyManager.purgeTriggerCount {
            // Instead of dequeuing on this tick, we need to purge
            paginatedDataSource.purgeOlderItems(limit: dependencyManager.purgeTargetCount)
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

private extension VDependencyManager {
    
    /// Max count before purge should occur.
    var purgeTriggerCount: Int {
        return numberForKey("purgeTriggerCount")?.integerValue ?? 100
    }
    
    /// How many items should remain after purge.
    var purgeTargetCount: Int {
        return numberForKey("purgeTargetCount")?.integerValue ?? 80
    }
}
