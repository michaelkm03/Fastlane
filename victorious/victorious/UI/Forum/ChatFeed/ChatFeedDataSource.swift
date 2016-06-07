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

class ChatFeedDataSource: NSObject, ForumEventSender, ForumEventReceiver, ChatInterfaceDataSource {
    
    // MARK: Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: - Managing content
    
    private(set) var visibleItems = [ContentModel]()
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
            
            visibleItems.appendContentsOf(stashedItems)
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
                visibleItems.appendContentsOf(newItems)
                delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .newer)
            }
        
        case .prependContent(let newItems):
            let newItems = newItems.map { $0 as ContentModel }
            visibleItems = newItems + visibleItems
            delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .older)
        
        case .replaceContent(let newItems):
            let newItems = newItems.map { $0 as ContentModel }
            visibleItems = newItems
            delegate?.chatFeedDataSource(self, didLoadItems: newItems, loadingType: .refresh)
        
        default:
            break
        }
    }
    
    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - ChatFeedNetworkDataSourceType
    
    weak var delegate: ChatFeedDataSourceDelegate?
    
    // MARK: - UICollectionViewDataSource
    
    let sizingCell: ChatFeedMessageCell = ChatFeedMessageCell.v_fromNib()
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(for: collectionView, in: section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellForItem(for: collectionView, at: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return desiredCellSize(for: collectionView, at: indexPath)
    }
}
