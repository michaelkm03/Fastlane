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
    var dependencyManager: VDependencyManager { get }
    
    var visibleItems: [ChatFeedContent] { get }
    
    func registerCells(for collectionView: UICollectionView)
    
    /// Calculated desired cell size for a given indexPath. 
    /// The size is based on the data object being displayed by the cell.
    func desiredCellSize(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize
    
    /// Decorates and configures a cell with its data object
    func decorate(cell: ChatFeedMessageCell, content: ContentModel)
}

extension ChatInterfaceDataSource {
    func numberOfItems(for collectionView: UICollectionView, in section: Int) -> Int {
        return visibleItems.count
    }
    
    func cellForItem(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> ChatFeedMessageCell {
        let content = visibleItems[indexPath.row].content
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(content.reuseIdentifier, forIndexPath: indexPath) as! ChatFeedMessageCell
        decorate(cell, content: content)
        
        return cell
    }
    
    func registerCells(for collectionView: UICollectionView) {
        collectionView.registerClass(ChatFeedMessageCell.self, forCellWithReuseIdentifier: ChatFeedMessageCell.imagePreviewCellReuseIdentifier)
        collectionView.registerClass(ChatFeedMessageCell.self, forCellWithReuseIdentifier: ChatFeedMessageCell.videoPreviewCellReuseIdentifier)
        collectionView.registerClass(ChatFeedMessageCell.self, forCellWithReuseIdentifier: ChatFeedMessageCell.nonMediaCellReuseIdentifier)
    }
    
    func desiredCellSize(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize {
        return visibleItems[indexPath.row].size
    }
    
    func decorate(cell: ChatFeedMessageCell, content: ContentModel) {
        cell.dependencyManager = dependencyManager
        cell.content = content
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
