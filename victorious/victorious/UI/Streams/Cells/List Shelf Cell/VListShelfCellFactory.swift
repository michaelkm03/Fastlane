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
    
    private let dependencyManager: VDependencyManager
    
    let failureCellFactory: VNoContentCollectionViewCellFactory = VNoContentCollectionViewCellFactory(acceptableContentClasses: nil)
    
    required init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager;
    }
}

extension VListShelfCellFactory: VStreamCellFactory {
    
    func registerCellsWithCollectionView(collectionView: UICollectionView) {
        collectionView.registerNib(VListPlaylistShelfCollectionViewCell.nibForCell(), forCellWithReuseIdentifier: VListPlaylistShelfCollectionViewCell.suggestedReuseIdentifier())
        collectionView.registerNib(VListRecentShelfCollectionViewCell.nibForCell(), forCellWithReuseIdentifier: VListRecentShelfCollectionViewCell.suggestedReuseIdentifier())
        failureCellFactory.registerNoContentCellWithCollectionView(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, cellForStreamItem streamItem: VStreamItem, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let shelf = streamItem as? Shelf {
            if streamItem.itemSubType == VStreamItemSubTypePlaylist {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(VListPlaylistShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? VListPlaylistShelfCollectionViewCell {
                    setup(cell, shelf: shelf, dependencyManager: dependencyManager)
                    return cell
                }
            } else if streamItem.itemSubType == VStreamItemSubTypeRecent {
                if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(VListRecentShelfCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? VListRecentShelfCollectionViewCell {
                    setup(cell, shelf: shelf, dependencyManager: dependencyManager)
                    return cell
                }
            }
        }
        assertionFailure("VListShelfCellFactory was provided a shelf that was neither a playlist shelf nor a recent shelf")
        return failureCellFactory.noContentCellForCollectionView(collectionView, atIndexPath: indexPath)
    }
    
    private func setup(cell: VListShelfCollectionViewCell, shelf: Shelf, dependencyManager: VDependencyManager) {
        cell.dependencyManager = dependencyManager
        cell.shelf = shelf;
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        if let shelf = streamItem as? ListShelf {
            if shelf.itemSubType == VStreamItemSubTypePlaylist {
                return VListPlaylistShelfCollectionViewCell.desiredSize(bounds, shelf: shelf, dependencyManager: dependencyManager)
            }
            else if shelf.itemSubType == VStreamItemSubTypeRecent {
                return VListRecentShelfCollectionViewCell.desiredSize(bounds, shelf: shelf, dependencyManager: dependencyManager)
            }
        }
        return CGSize.zero
    }
    
    func minimumLineSpacing() -> CGFloat {
        return 7.0
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 11, 11, 11)
    }
    
}
