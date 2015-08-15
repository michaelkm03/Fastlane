//
//  VTrendingShelfCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

///A cell factory that returns trending content shelves
class VTrendingShelfCellFactory: NSObject {
    private let dependencyManager : VDependencyManager
    
    required init!(dependencyManager: VDependencyManager!) {
        self.dependencyManager = dependencyManager;
    }
}

extension VTrendingShelfCellFactory: VStreamCellFactory {
    func registerCellsWithCollectionView(collectionView: UICollectionView) {
        collectionView.registerNib(VTrendingUserShelfCollectionViewCell.nibForCell(), forCellWithReuseIdentifier: VTrendingUserShelfCollectionViewCell.suggestedReuseIdentifier())
        collectionView.registerNib(VTrendingHashtagShelfCollectionViewCell.nibForCell(), forCellWithReuseIdentifier: VTrendingHashtagShelfCollectionViewCell.suggestedReuseIdentifier())
    }
    
    func collectionView(collectionView: UICollectionView, cellForStreamItem streamItem: VStreamItem, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell? = nil
        if let shelf = streamItem as? UserShelf {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(VTrendingUserShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? UICollectionViewCell
            if let cell = cell as? VTrendingUserShelfCollectionViewCell {
                setup(cell, shelf: shelf, dependencyManager: dependencyManager)
            }
        } else if let shelf = streamItem as? HashtagShelf {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(VTrendingHashtagShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? UICollectionViewCell
            if let cell = cell as? VTrendingHashtagShelfCollectionViewCell {
                setup(cell, shelf: shelf, dependencyManager: dependencyManager)
            }
        }
        if cell == nil {
            cell = UICollectionViewCell()
            assertionFailure("VTrendingShelfCellFactory was provided a shelf that was neither a user shelf nor a hashtag shelf")
        }
        return cell!
    }
    
    private func setup(cell: VTrendingShelfCollectionViewCell, shelf: VShelf, dependencyManager: VDependencyManager) {
        cell.dependencyManager = dependencyManager
        cell.shelf = shelf;
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        if let shelf = streamItem as? UserShelf {
            return VTrendingUserShelfCollectionViewCell.desiredSize(collectionViewBounds: bounds, shelf: shelf, dependencyManager: dependencyManager)
        }
        else if let shelf = streamItem as? HashtagShelf {
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