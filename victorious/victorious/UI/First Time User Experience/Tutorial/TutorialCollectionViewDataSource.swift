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
    weak var delegate: TutotrialCollectionViewDataSourceDelegate?
    
    lazy var networkDataSource: NetworkDataSource = {
        let dataSource = TutorialNetworkDataSource(dependencyManager: self.dependencyManager)
        dataSource.delegate = self
        
        return dataSource
    }()
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - ChatInterfaceDataSource
    
    let sizingCell: ChatFeedMessageCell = ChatFeedMessageCell.v_fromNib()
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(collectionView, in: section)
    }
    
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        return cellForItem(collectionView, at: indexPath)
    }
    
    func decorateCell(cell: ChatFeedMessageCell, item: ChatMessageType) {
        cell.layout = LeftAlignmentCellLayout()
        cell.dependencyManager = dependencyManager
        cell.cellContent = item
    }
    
    func registerCells(with collectionView: UICollectionView) {
        let identifier = ChatFeedMessageCell.suggestedReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: ChatFeedMessageCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    // MARK: - TutorialNetworkDataSourceDelegate
    
    func didUpdateVisibleItems(from oldValue: [ChatMessageType], to newValue: [ChatMessageType]) {
        
    }
    
    func didFinishFetchingAllItems() {
        delegate?.didFinishFetchingAllItems()
    }
}

protocol TutotrialCollectionViewDataSourceDelegate: class {
    func didFinishFetchingAllItems()
}
