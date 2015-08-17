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
        if let shelf = streamItem as? VShelf {
            if streamItem.itemType == VStreamItemTypePlaylist {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(VListPlaylistShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? VListPlaylistShelfCollectionViewCell {
                    setup(cell, shelf: shelf, dependencyManager: dependencyManager)
                    return cell
                }
            } else if streamItem.itemType == VStreamItemTypeRecent {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(VListRecentShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? VListRecentShelfCollectionViewCell {
                    setup(cell, shelf: shelf, dependencyManager: dependencyManager)
                    return cell
                }
            }
        }
        let cell = UICollectionViewCell()
        assertionFailure("VListShelfCellFactory was provided a shelf that was neither a user shelf nor a hashtag shelf")
        return cell
    }
    
    private func setup(cell: VListShelfCollectionViewCell, shelf: VShelf, dependencyManager: VDependencyManager) {
        cell.dependencyManager = dependencyManager
        cell.shelf = shelf;
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        if let shelf = streamItem as? ListShelf {
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
