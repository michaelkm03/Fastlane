//
//  VListShelfCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A cell factory that returns list content shelves
class VListShelfCellFactory: NSObject {
    
    private let dependencyManager : VDependencyManager
    
    required init!(dependencyManager: VDependencyManager!) {
        self.dependencyManager = dependencyManager;
    }
    
}

extension VListShelfCellFactory: VStreamCellFactory {
    
    func registerCellsWithCollectionView(collectionView: UICollectionView) {
        collectionView.registerNib(VListPlaylistShelfCollectionViewCell.nibForCell(), forCellWithReuseIdentifier: VListPlaylistShelfCollectionViewCell.suggestedReuseIdentifier())
        collectionView.registerNib(VListRecentShelfCollectionViewCell.nibForCell(), forCellWithReuseIdentifier: VListRecentShelfCollectionViewCell.suggestedReuseIdentifier())
    }
    
    func collectionView(collectionView: UICollectionView, cellForStreamItem streamItem: VStreamItem, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell? = nil
        if let shelf = streamItem as? VShelf {
            if streamItem.itemType == VStreamItemTypePlaylist {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(VListPlaylistShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? UICollectionViewCell
                if let cell = cell as? VListPlaylistShelfCollectionViewCell {
                    setup(cell, shelf: shelf, dependencyManager: dependencyManager)
                }
            } else if streamItem.itemType == VStreamItemTypeRecent {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(VListRecentShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? UICollectionViewCell
                if let cell = cell as? VListRecentShelfCollectionViewCell {
                    setup(cell, shelf: shelf, dependencyManager: dependencyManager)
                }
            }
        }
        if cell == nil {
            cell = UICollectionViewCell()
            assertionFailure("VListShelfCellFactory was provided a shelf that was neither a user shelf nor a hashtag shelf")
        }
        return cell!
    }
    
    private func setup(cell: VListShelfCollectionViewCell, shelf: VShelf, dependencyManager: VDependencyManager) {
        cell.dependencyManager = dependencyManager
        cell.shelf = shelf;
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        if let shelf = streamItem as? VShelf {
            if shelf.itemType == VStreamItemTypePlaylist {
                return VListPlaylistShelfCollectionViewCell.desiredSize(bounds, shelf: shelf, dependencyManager: dependencyManager)
            }
            else if shelf.itemType == VStreamItemTypeRecent {
                return VListRecentShelfCollectionViewCell.desiredSize(bounds, shelf: shelf, dependencyManager: dependencyManager)
            }
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
