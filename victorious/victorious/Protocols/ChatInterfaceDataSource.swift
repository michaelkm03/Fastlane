//
//  ChatInterfaceDataSource.swift
//  victorious
//
//  Created by Tian Lan on 5/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Conformers are collection view data sources for any collection views with a chat-like interface
protocol ChatInterfaceDataSource: UICollectionViewDataSource {
    /// The dependency manager associated with the data source.
    var dependencyManager: VDependencyManager { get }
    
    /// The chat feed items that are currently visible in the feed.
    var visibleItems: [ChatFeedContent] { get }
    
    /// Items that are pending insertion into the feed which will be shown at the bottom of the feed.
    var pendingItems: [ChatFeedContent] { get }
    
    /// Registers the appropriate collection view cells on `collectionView`.
    func registerCells(for collectionView: UICollectionView)
    
    /// Calculated desired cell size for a given indexPath. 
    /// The size is based on the data object being displayed by the cell.
    func desiredCellSize(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize
    
    /// Decorates and configures a cell with its data object
    func decorate(cell: ChatFeedMessageCell, with chatFeedContent: ChatFeedContent)
}

extension ChatInterfaceDataSource {
    var itemCount: Int {
        return visibleItems.count + pendingItems.count
    }
    
    func content(at index: Int) -> ChatFeedContent {
        if index < visibleItems.count {
            return visibleItems[index]
        }
        else {
            return pendingItems[index - visibleItems.count]
        }
    }
    
    func numberOfItems(for collectionView: UICollectionView, in section: Int) -> Int {
        return itemCount
    }
    
    func cellForItem(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> ChatFeedMessageCell {
        let chatFeedContent = content(at: indexPath.row)
        let reuseIdentifier = chatFeedContent.content.reuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ChatFeedMessageCell
        decorate(cell, with: chatFeedContent)
        return cell
    }
    
    func registerCells(for collectionView: UICollectionView) {
        collectionView.registerClass(ChatFeedMessageCell.self, forCellWithReuseIdentifier: ChatFeedMessageCell.imagePreviewCellReuseIdentifier)
        collectionView.registerClass(ChatFeedMessageCell.self, forCellWithReuseIdentifier: ChatFeedMessageCell.videoPreviewCellReuseIdentifier)
        collectionView.registerClass(ChatFeedMessageCell.self, forCellWithReuseIdentifier: ChatFeedMessageCell.nonMediaCellReuseIdentifier)
    }
    
    func desiredCellSize(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize {
        return content(at: indexPath.row).size
    }
    
    func decorate(cell: ChatFeedMessageCell, with chatFeedContent: ChatFeedContent) {
        cell.dependencyManager = dependencyManager
        cell.chatFeedContent = chatFeedContent
    }
    
    func updateTimestamps(in collectionView: UICollectionView) {
        for indexPath in collectionView.indexPathsForVisibleItems() {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ChatFeedMessageCell
            cell.updateTimestamp()
        }
    }
}

extension ContentModel {
    var reuseIdentifier: String {
        if type.previewsAsVideo {
            return ChatFeedMessageCell.videoPreviewCellReuseIdentifier
        }
        else if type.previewsAsImage {
            return ChatFeedMessageCell.imagePreviewCellReuseIdentifier
        }
        
        return ChatFeedMessageCell.nonMediaCellReuseIdentifier
    }
}
