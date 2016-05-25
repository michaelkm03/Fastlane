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
    var sizingCell: ChatFeedMessageCell { get }
    
    var dependencyManager: VDependencyManager { get }
    
    /// The network data source that's in charge of fetching data from the network
    var networkDataSource: NetworkDataSource { get }
    
    func registerCells(for collectionView: UICollectionView)
    
    /// Calculated desired cell size for a given indexPath. 
    /// The size is based on the data object being displayed by the cell.
    func desiredCellSize(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize
    
    /// Decorates and configures a cell with its data object
    func decorate(cell: ChatFeedMessageCell, content: ContentModel)
}

extension ChatInterfaceDataSource {
    
    var sizingCell: ChatFeedMessageCell {
        return ChatFeedMessageCell.v_fromNib()
    }
    
    func numberOfItems(for collectionView: UICollectionView, in section: Int) -> Int {
        return networkDataSource.visibleItems.count
    }
    
    func cellForItem(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> ChatFeedMessageCell {
        let identifier = ChatFeedMessageCell.defaultReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ChatFeedMessageCell
        let content = networkDataSource.visibleItems[indexPath.row]
        decorate(cell, content: content)
        return cell
    }
    
    func registerCells(for collectionView: UICollectionView) {
        let identifier = ChatFeedMessageCell.suggestedReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: ChatFeedMessageCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func desiredCellSize(for collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize {
        let content = networkDataSource.visibleItems[indexPath.row]
        decorate(sizingCell, content: content)
        return sizingCell.cellSizeWithinBounds(collectionView.bounds)
    }
    
    func decorate(cell: ChatFeedMessageCell, content: ContentModel) {
        if VCurrentUser.user()?.remoteId.integerValue == content.author?.id {
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
            let content = networkDataSource.visibleItems[indexPath.row]
            decorate(cell, content: content)
        }
    }
}
