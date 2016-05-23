//
//  ChatFeedCollectionDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 3/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ChatFeedCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    let sizingCell: ChatFeedMessageCell = ChatFeedMessageCell.v_fromNib()
    
    let dependencyManager: VDependencyManager
    let paginatedDataSource: PaginatedDataSource
    
    init( paginatedDataSource: PaginatedDataSource, dependencyManager: VDependencyManager ) {
        self.paginatedDataSource = paginatedDataSource
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paginatedDataSource.visibleItems.count
    }
    
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        let identifier = ChatFeedMessageCell.suggestedReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ChatFeedMessageCell
        let message = paginatedDataSource.visibleItems[ indexPath.row ] as! ChatFeedMessage
        decorateCell(cell, message: message, dependencyManager: dependencyManager)
        return cell
    }
    
    // MARK: - Collection data source helpers
    
    func updateTimeStamps(collectionView: UICollectionView) {
        for indexPath in collectionView.indexPathsForVisibleItems() {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ChatFeedMessageCell
            let message = paginatedDataSource.visibleItems[ indexPath.row ] as! ChatFeedMessage
            decorateCell(cell, message: message, dependencyManager: dependencyManager)
        }
    }
    
    private func decorateCell(cell: ChatFeedMessageCell, message: DisplayableChatMessage, dependencyManager: VDependencyManager) {
        if VCurrentUser.user()?.remoteId.integerValue == message.userID {
            cell.layout = RightAlignmentCellLayout()
        } else {
            cell.layout = LeftAlignmentCellLayout()
        }
        
        cell.dependencyManager = dependencyManager
        cell.cellContent = message
    }
    
    func registerCellsWithCollectionView( collectionView: UICollectionView ) {
        let identifier = ChatFeedMessageCell.suggestedReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: ChatFeedMessageCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func collectionView(collectionView: UICollectionView, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let message = paginatedDataSource.visibleItems[ indexPath.row ] as! ChatFeedMessage
        decorateCell(sizingCell, message: message, dependencyManager: dependencyManager)
        return sizingCell.cellSizeWithinBounds(collectionView.bounds)
    }
}
