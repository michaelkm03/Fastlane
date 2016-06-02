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
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didLoadItems newItems: [ContentModel], loadingType: PaginatedLoadingType)
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didStashItems stashedItems: [ContentModel])
    func chatFeedDataSource(dataSource: ChatFeedDataSource, didUnstashItems unstashedItems: [ContentModel])
}

class ChatFeedDataSource: NSObject, ForumEventSender, ForumEventReceiver, UICollectionViewDataSource {
    // MARK: Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: - Managing content
    
    private(set) var unstashedItems = [ContentModel]()
    private(set) var stashedItems = [ContentModel]()
    
    var stashingEnabled = false
    
    private var justUnstashed = false
    
    private var shouldStash: Bool {
        return stashingEnabled && !justUnstashed
    }
    
    func unstash() {
        if stashedItems.count > 0 {
            justUnstashed = true
            
            let previouslyStashedItems = stashedItems
            
            unstashedItems.appendContentsOf(stashedItems)
            stashedItems.removeAll()
            
            delegate?.chatFeedDataSource(self, didUnstashItems: previouslyStashedItems)
            
            dispatch_after(1.0) { [weak self] in
                self?.justUnstashed = false
            }
        }
    }
    
    // MARK: - ForumEventReceiver
    
    func receive(event: ForumEvent) {
        switch event {
        case .appendContent(let newItems):
            let newItems = newItems.map { $0 as ContentModel }
            
            if shouldStash {
                stashedItems.appendContentsOf(newItems)
                delegate?.chatFeedDataSource(self, didStashItems: newItems)
            } else {
                unstashedItems.appendContentsOf(newItems)
                delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .newer)
            }
        
        case .prependContent(let newItems):
            let newItems = newItems.map { $0 as ContentModel }
            unstashedItems = newItems + unstashedItems
            delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .older)
        
        case .replaceContent(let newItems):
            let newItems = newItems.map { $0 as ContentModel }
            unstashedItems = newItems
            delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .refresh)
        
        default:
            break
        }
    }
    
    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - ChatFeedNetworkDataSourceType
    
    weak var delegate: ChatFeedDataSourceDelegate?
    
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
        return unstashedItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = ChatFeedMessageCell.suggestedReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ChatFeedMessageCell
        decorateCell(cell, content: unstashedItems[indexPath.row], dependencyManager: dependencyManager)
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
        decorateCell(sizingCell, content: unstashedItems[indexPath.row], dependencyManager: dependencyManager)
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
