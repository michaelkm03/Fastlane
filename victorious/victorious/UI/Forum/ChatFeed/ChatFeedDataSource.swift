//
//  ChatFeedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

protocol ChatFeedDataSourceDelegate: class {
    func chatFeedDataSource(dataSource: ChatFeedDataSourceType, didLoadItems newItems: [ContentModel], loadingType: PaginatedLoadingType)
}

protocol ChatFeedDataSourceType: ForumEventReceiver, ForumEventSender, UICollectionViewDataSource {
    var items: [ContentModel] { get }
    
    weak var delegate: ChatFeedDataSourceDelegate? { get set }
    
    func startCheckingForNewItems()
    func stopCheckingForNewItems()
    
    func registerCells(for collectionView: UICollectionView)
    func collectionView(collectionView: UICollectionView, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    
    func updateTimestamps(for collectionView: UICollectionView)
}

class ChatFeedDataSource: NSObject, ChatFeedDataSourceType {
//    private let eventQueue = ReceivedEventQueue<ChatFeedMessage>()
    
    /// If this interval is too small, the scrolling animations will become choppy
    /// as they step on each other before finishing.
//    private var fetchMessageInterval: NSTimeInterval = 1.0
    
//    private var timerManager: VTimerManager?
    
//    private var eventCounter = Int.max
    
    // MARK: Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
//    deinit {
//        stopCheckingForNewItems()
//    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: - Managing content
    
    private(set) var items = [ContentModel]()
    
    // MARK: - ForumEventReceiver
    
    func receive(event: ForumEvent) {
        switch event {
        case .appendContent(let newItems):
            items.appendContentsOf(newItems.map { $0 as ContentModel })
            delegate?.chatFeedDataSource(self, didLoadItems: newItems.map { $0 as ContentModel }, loadingType: .newer)
        case .prependContent(let newItems):
            items = newItems.map { $0 as ContentModel } + items
            delegate?.chatFeedDataSource(self, didLoadItems: newItems.map { $0 as ContentModel }, loadingType: .older)
        case .replaceContent(let newItems):
            items = newItems.map { $0 as ContentModel }
            delegate?.chatFeedDataSource(self, didLoadItems: newItems.map { $0 as ContentModel }, loadingType: .refresh)
            break
        default:
            break
        }
    }
    
    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - ChatFeedNetworkDataSourceType
    
    weak var delegate: ChatFeedDataSourceDelegate?
    
    func startCheckingForNewItems() {
//        guard timerManager == nil else {
//            return
//        }
//        timerManager = VTimerManager.addTimerManagerWithTimeInterval(
//            fetchMessageInterval,
//            target: self,
//            selector: #selector(onTimerTick),
//            userInfo: nil,
//            repeats: true,
//            toRunLoop: NSRunLoop.mainRunLoop(),
//            withRunMode: NSRunLoopCommonModes
//        )
//        dequeueMessages()
    }
    
    func stopCheckingForNewItems() {
//        timerManager?.invalidate()
//        timerManager = nil
    }
    
    func onTimerTick() {
        // TODO: Implement purging.
//        if paginatedDataSource.visibleItems.count > dependencyManager.purgeTriggerCount {
//            // Instead of dequeuing on this tick, we need to purge
//            paginatedDataSource.purgeOlderItems(limit: dependencyManager.purgeTargetCount)
//        } else {
//            // Now we can continue dequeuing
//            dequeueMessages()
//        }
    }
    
//    private func dequeueMessages() {
//        paginatedDataSource.loadNewItems(
//            createOperation: {
//                let messages = eventQueue.dequeueAll()
//                return DequeueMessagesOperation(messages: messages)
//            },
//            completion: nil
//        )
//    }
    
    // MARK: - Managing timestamps
    
    func updateTimestamps(for collectionView: UICollectionView) {
        for indexPath in collectionView.indexPathsForVisibleItems() {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ChatFeedMessageCell
            cell.updateTimestamp()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    private let sizingCell: ChatFeedMessageCell = ChatFeedMessageCell.v_fromNib()
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = ChatFeedMessageCell.suggestedReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ChatFeedMessageCell
        decorateCell(cell, content: items[indexPath.row], dependencyManager: dependencyManager)
        return cell
    }
    
    private func decorateCell(cell: ChatFeedMessageCell, content: ContentModel, dependencyManager: VDependencyManager) {
        if VCurrentUser.user()?.remoteId.integerValue == content.authorModel.id {
            cell.layout = RightAlignmentCellLayout()
        } else {
            cell.layout = LeftAlignmentCellLayout()
        }
        
        if cell.dependencyManager == nil {
            cell.dependencyManager = dependencyManager
        }
        
        cell.content = content
    }
    
    func registerCells(for collectionView: UICollectionView) {
        let identifier = ChatFeedMessageCell.suggestedReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: ChatFeedMessageCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func collectionView(collectionView: UICollectionView, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        decorateCell(sizingCell, content: items[indexPath.row], dependencyManager: dependencyManager)
        return sizingCell.cellSizeWithinBounds(collectionView.bounds)
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
