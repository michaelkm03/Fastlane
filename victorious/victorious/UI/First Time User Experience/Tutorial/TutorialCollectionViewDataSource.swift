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
    
    var visibleItems: [ContentModel] {
        return networkDataSource.visibleItems
    }
    
    lazy var networkDataSource: NetworkDataSource = {
        let dataSource = TutorialNetworkDataSource(dependencyManager: self.dependencyManager)
        dataSource.delegate = self
        
        return dataSource
    }()
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - ChatInterfaceDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(for: collectionView, in: section)
    }
    
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        return cellForItem(for: collectionView, at: indexPath)
    }
    
    // MARK: - TutorialNetworkDataSourceDelegate
    
    func didUpdateVisibleItems(from oldValue: [ContentModel], to newValue: [ContentModel]) {
        delegate?.didUpdateVisibleItems(from: oldValue, to: newValue)
    }
    
    func didFinishFetchingAllItems() {
        delegate?.didFinishFetchingAllItems()
    }
}
