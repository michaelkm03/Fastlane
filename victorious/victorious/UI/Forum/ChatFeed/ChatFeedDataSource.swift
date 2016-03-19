//
//  ChatFeedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK
import KVOController

class ForumEventQueue {
    
    let maximimEventCount: Int?
    
    init(maximimEventCount: Int? = nil) {
        self.maximimEventCount = maximimEventCount
    }
    
    private var events = [ForumEvent]()
    
    func addEvent(event: ForumEvent) {
        if let max = maximimEventCount where events.count + 1 >= max {
            events.removeLast()
        }
        events.append(event)
    }
    
    func dequeueEvents(count count: Int) -> [ForumEvent] {
        guard count <= events.count else {
            return dequeueAll()
        }
        let output = events[0..<count]
        events.removeRange(count..<events.count)
        return Array(output)
    }
    
    func dequeueAll() -> [ForumEvent] {
        let output = events
        events = []
        return output
    }
}

class ChatFeedDataSource: PaginatedDataSource, ForumEventReceiver, UICollectionViewDataSource {
    
    private let itemsPerPage = 10
    
    private let eventQueue = ForumEventQueue()
    
    /// If this interval is too small, the scrolling animations will become choppy
    /// as they step on each other before finishing.
    private var fetchMessageInterval: NSTimeInterval = 1.5
    
    private var timerManager: VTimerManager?
    
    let dependencyManager: VDependencyManager
    
    var shouldStashNewContent: Bool = false
    
    let cellDecorator = MessageCellDecorator()
    let sizingCell: MessageCell = MessageCell.v_fromNib()
    
    init( dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - ForumEventReceiver
    
    func receiveEvent(event: ForumEvent) {
        // Stash events in the queue when received and wait to dequeue on our timer cycle
        eventQueue.addEvent(event)
    }
    
    // MARK: - Live Update
    
    func startDequeueingMessages() {
        guard timerManager == nil else {
            return
        }
        timerManager = VTimerManager.addTimerManagerWithTimeInterval(fetchMessageInterval,
            target: self,
            selector: Selector("dequeueMessages"),
            userInfo: nil,
            repeats: true, 
            toRunLoop: NSRunLoop.mainRunLoop(),
            withRunMode: NSRunLoopCommonModes
        )
        dequeueMessages()
    }
    
    func stopDequeueingMessages() {
        timerManager?.invalidate()
        timerManager = nil
    }
    
    func dequeueMessages() {
        loadNewItems(
            createOperation: {
                let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: itemsPerPage)
                return DequeueMessagesOperation(events: eventQueue.dequeueAll(), paginator: paginator)
            },
            completion: nil
        )
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        let identifier = MessageCell.suggestedReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! MessageCell
        let message = visibleItems[ indexPath.row ] as! ChatMessage
        cellDecorator.decorateCell(cell, withMessage: message, dependencyManager: dependencyManager.fanCellDependency)
        return cell
    }
    
    func registerCellsWithCollectionView( collectionView: UICollectionView ) {
        let identifier = MessageCell.suggestedReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: MessageCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let message = visibleItems[ indexPath.row ] as! ChatMessage
        var bounds = sizingCell.bounds
        bounds.size.width = collectionView.bounds.width
        sizingCell.bounds = bounds
        cellDecorator.decorateCell(sizingCell, withMessage: message, dependencyManager: dependencyManager.fanCellDependency)
        return sizingCell.cellSizeWithinBounds(collectionView.bounds)
    }
    
    func redecorateVisibleCells(collectionView: UICollectionView) {
        for indexPath in collectionView.indexPathsForVisibleItems() {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MessageCell
            let message = visibleItems[ indexPath.row ] as! ChatMessage
            cellDecorator.decorateCell(cell, withMessage:message, dependencyManager: dependencyManager.fanCellDependency)
        }
    }
}

private extension VDependencyManager {
    
    var fanCellDependency: VDependencyManager {
        return childDependencyForKey("cell.fan")!
    }
    
    var creatorCellDependency: VDependencyManager {
        return childDependencyForKey("cell.creator")!
    }
}
