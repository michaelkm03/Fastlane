//
//  ChatInterfaceDataSource.swift
//  victorious
//
//  Created by Tian Lan on 5/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers are collection view data sources for any collection views with a chat-like interface
protocol ChatInterfaceDataSource: UICollectionViewDataSource {
    
    /// A standalone cell used to calculate dynamic cell sizes
    /// - Note: Each concrete implementation should provide a stored sizing cell, because it temporarily stores cell content to size the cell
    var sizingCell: ChatFeedMessageCell { get }
    
    var dependencyManager: VDependencyManager { get }
    
    var visibleItems: [ContentModel] { get }
    
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
        let content = visibleItems[indexPath.row]
        let reuseIdentifier = content.type.hasMedia ? ChatFeedMessageCell.mediaCellReuseIdentifier : ChatFeedMessageCell.nonMediaCellReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ChatFeedMessageCell
        decorate(cell, content: content)
        
        return cell
    }
    
    func registerCells(for collectionView: UICollectionView) {
        collectionView.registerClass(ChatFeedMessageCell.self, forCellWithReuseIdentifier: ChatFeedMessageCell.mediaCellReuseIdentifier)
        collectionView.registerClass(ChatFeedMessageCell.self, forCellWithReuseIdentifier: ChatFeedMessageCell.nonMediaCellReuseIdentifier)
    }
    
    func desiredCellSize(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize {
        let content = visibleItems[indexPath.row]
        decorate(sizingCell, content: content)
        
        return sizingCell.cellSizeWithinBounds(collectionView.bounds)
    }
    
    func decorate(cell: ChatFeedMessageCell, content: ContentModel) {
        if VCurrentUser.user()?.remoteId.integerValue == content.authorModel.id {
            cell.layout = RightAlignmentCellLayout()
        } else {
            cell.layout = LeftAlignmentCellLayout()
        }
        
        cell.dependencyManager = dependencyManager
        cell.content = content
    }
    
    func updateTimeStamps(in collectionView: UICollectionView) {
        for indexPath in collectionView.indexPathsForVisibleItems() {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ChatFeedMessageCell
            cell.updateTimestamp()
        }
    }
}
