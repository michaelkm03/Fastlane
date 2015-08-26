//
//  TrendingTopicShelfFactory.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A cell factory that returns trending content shelves
class TrendingTopicShelfFactory: NSObject {
    
    private let dependencyManager: VDependencyManager
    
    required init!(dependencyManager: VDependencyManager!) {
        self.dependencyManager = dependencyManager;
    }
    
}

extension TrendingTopicShelfFactory: VStreamCellFactory {
    
    func registerCellsWithCollectionView(collectionView: UICollectionView) {
        collectionView.registerClass(TrendingTopicShelfCollectionViewCell.self, forCellWithReuseIdentifier: TrendingTopicShelfCollectionViewCell.suggestedReuseIdentifier())
    }
    
    func collectionView(collectionView: UICollectionView, cellForStreamItem streamItem: VStreamItem, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let newShelf = streamItem as? Shelf {
            if newShelf.itemSubType == VStreamItemSubTypeTrendingTopic {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TrendingTopicShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? TrendingTopicShelfCollectionViewCell {
                    cell.shelf = newShelf
                    cell.dependencyManager = dependencyManager
                    return cell
                }
            }
        }
        let cell = UICollectionViewCell()
        assertionFailure("TrendingTopicShelfFactory was provided a shelf that was not a trending topic shelf")
        return cell
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        if let shelf = streamItem as? Shelf {
            return TrendingTopicShelfCollectionViewCell.desiredSize(collectionViewBounds: bounds, shelf: shelf, dependencyManager: dependencyManager)
        }
        return CGSize.zeroSize
    }
    
    func minimumLineSpacing() -> CGFloat {
        return 7.0
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 11, 11, 11)
    }
    
}