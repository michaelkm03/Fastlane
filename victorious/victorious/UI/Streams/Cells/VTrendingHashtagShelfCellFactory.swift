//
//  VTrendingHashtagShelfCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VTrendingHashtagShelfCellFactory: NSObject, VStreamCellFactory {
    
    let dependencyManager : VDependencyManager
    
    required init!(dependencyManager: VDependencyManager!) {
        self.dependencyManager = dependencyManager;
    }
    
    func registerCellsWithCollectionView(collectionView: UICollectionView) {
        collectionView.registerNib(VTrendingHashtagShelfCollectionViewCell.nibForCell(), forCellWithReuseIdentifier: VTrendingHashtagShelfCollectionViewCell.suggestedReuseIdentifier())
    }
    
    func collectionView(collectionView: UICollectionView, cellForStreamItem streamItem: VStreamItem, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(VTrendingHashtagShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as! UICollectionViewCell
        if let cell = cell as? VTrendingHashtagShelfCollectionViewCell {
            cell.dependencyManager = dependencyManager
            if let shelf = streamItem as? VShelf {
                cell.shelf = shelf;
            }
        }
        return cell;
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        if let shelf = streamItem as? HashtagShelf {
            return VTrendingHashtagShelfCollectionViewCell.desiredSize(collectionViewBounds: bounds, shelf: shelf, dependencyManager: dependencyManager)
        }
        return CGSize.zeroSize
    }
    
    func minimumLineSpacing() -> CGFloat {
        return 11.0
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 15, 15, 0)
    }
    
}
