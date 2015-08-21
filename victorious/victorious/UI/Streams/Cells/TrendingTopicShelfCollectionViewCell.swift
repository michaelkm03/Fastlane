//
//  TrendingTopicShelfCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class TrendingTopicShelfCollectionViewCell: VBaseCollectionViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var shelf: Shelf? {
        didSet {
            if ( shelf == oldValue ) {
                if let newStreamItems = streamItems(shelf), let oldStreamItems = streamItems(oldValue) {
                    if newStreamItems.isEqualToOrderedSet(oldStreamItems) {
                        //The shelf AND its content are the same, no need to update
                        return
                    }
                }
            }
            onShelfSet()
            collectionView.reloadData()
        }
    }
    
    private func onShelfSet() {
        if let streamItems = streamItems(shelf)?.array as? [VStreamItem] {
            for (index, streamItem) in enumerate(streamItems) {
                 collectionView.registerClass(TrendingTopicContentCollectionViewCell.self, forCellWithReuseIdentifier: TrendingTopicContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager))
            }
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager == oldValue {
                return
            }
            
            // TODO: Customize
        }
    }
    
    private func streamItems(shelf: Shelf?) -> NSOrderedSet? {
        return shelf?.streamItems
    }
}

extension TrendingTopicShelfCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamItems(shelf)?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let streamItems = streamItems(shelf)?.array as? [VStreamItem] {
            let streamItem = streamItems[indexPath.row]
            let reuseIdentifier = TrendingTopicContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TrendingTopicContentCollectionViewCell
            cell.streamItem = streamItem
            cell.dependencyManager = dependencyManager
            return cell
        }
        assertionFailure("TrendingTopicShelfCollectionViewCell was asked to display an object that isn't a stream item.")
        return UICollectionViewCell()
    }
}

extension TrendingTopicShelfCollectionViewCell: UICollectionViewDelegate {
    
}

extension TrendingTopicShelfCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(90, 90)
    }
    
}
