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
    
    func registerCells(with collectionView: UICollectionView)
    
    /// Calculated desired cell size for a given indexPath. 
    /// The size is based on the data object being displayed by the cell.
    func desiredCellSize(collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize
    
    /// Decorates and configures a cell with its data object
    func decorateCell(cell: ChatFeedMessageCell, item: ChatMessageType)
}

extension ChatInterfaceDataSource {
    
    func numberOfItems(collectionView: UICollectionView, in section: Int) -> Int {
        return networkDataSource.visibleItems.count
    }
    
    func cellForItem(collectionView: UICollectionView, at indexPath: NSIndexPath) -> ChatFeedMessageCell {
        let identifier = ChatFeedMessageCell.defaultReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ChatFeedMessageCell
        let item = networkDataSource.visibleItems[indexPath.row]
        decorateCell(cell, item: item)
        return cell
    }
    
    func desiredCellSize(collectionView: UICollectionView, at indexPath: NSIndexPath) -> CGSize {
        let item = networkDataSource.visibleItems[ indexPath.row ]
        decorateCell(sizingCell, item: item)
        return sizingCell.cellSizeWithinBounds(collectionView.bounds)
    }
}
