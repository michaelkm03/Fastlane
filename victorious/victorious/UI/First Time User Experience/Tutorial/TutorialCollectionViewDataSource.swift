//
//  TutorialCollectionViewDataSource.swift
//  victorious
//
//  Created by Tian Lan on 5/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class TutorialCollectionViewDataSource: NSObject, ChatInterfaceDataSource, TutorialNetworkDataSourceDelegate {
    let dependencyManager: VDependencyManager
    weak var delegate: TutorialNetworkDataSourceDelegate?
    
    let sizingCell = ChatFeedMessageCell(frame: CGRectZero)
    
    lazy var networkDataSource: NetworkDataSource = {
        let dataSource = TutorialNetworkDataSource(dependencyManager: self.dependencyManager)
        dataSource.delegate = self
        return dataSource
    }()
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - ChatInterfaceDataSource
    
    var unstashedItems: [ChatFeedContent] {
        return networkDataSource.visibleItems
    }
    
    let pendingItems = [ChatFeedContent]()
    
    func removeUnstashedItem(at index: Int) {
        assertionFailure("Removing items is not supported in the tutorial.")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(for: collectionView, in: section)
    }
    
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        let cell = cellForItem(for: collectionView, at: indexPath)
        cell.timestampLabel.hidden = true
        cell.likeCountLabel.hidden = true
        
        return cell
    }
    
    // MARK: - TutorialNetworkDataSourceDelegate
    
    func didReceiveNewMessage(message: ChatFeedContent) {
        delegate?.didReceiveNewMessage(message)
    }
    
    func didFinishFetchingAllItems() {
        delegate?.didFinishFetchingAllItems()
    }
    
    var chatFeedItemWidth: CGFloat {
        return delegate?.chatFeedItemWidth ?? 0.0
    }
}
