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
    
    /// The number of items displayed in the chat interface.
    var itemCount: Int { get }
    
    /// Returns the content at the given `index`.
    func content(at index: Int) -> ChatFeedContent
    
    func registerCells(for collectionView: UICollectionView)
    
    /// Calculated desired cell size for a given indexPath. 
    /// The size is based on the data object being displayed by the cell.
    func desiredCellSize(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize
    
    /// Decorates and configures a cell with its data object
    func decorate(cell: ChatFeedMessageCell, content: ContentModel)
}

extension ChatInterfaceDataSource {
    func numberOfItems(for collectionView: UICollectionView, in section: Int) -> Int {
        return itemCount
    }
    
    func cellForItem(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> ChatFeedMessageCell {
        let content = self.content(at: indexPath.row).content
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
        let chatFeedContent = content(at: indexPath.row)
        
        if let size = chatFeedContent.size {
            return size
        }
        else {
            let width = collectionView.bounds.width
            let height = ChatFeedMessageCell.cellHeight(displaying: chatFeedContent.content, inWidth: width, dependencyManager: dependencyManager)
            let size = CGSize(width: width, height: height)
            chatFeedContent.size = size
            return size
        }
        
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
