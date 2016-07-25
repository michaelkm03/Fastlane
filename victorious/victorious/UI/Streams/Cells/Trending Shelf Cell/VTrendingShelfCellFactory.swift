//
//  VTrendingShelfCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A cell factory that returns trending content shelves
class VTrendingShelfCellFactory: NSObject {
    
    private let dependencyManager: VDependencyManager
    
    private let failureCellFactory = VNoContentCollectionViewCellFactory(acceptableContentClasses: nil)

    required init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager;
    }
}

extension VTrendingShelfCellFactory: VStreamCellFactory {
    
    func registerCellsWithCollectionView(collectionView: UICollectionView) {
    }
    
    func collectionView(collectionView: UICollectionView, cellForStreamItem streamItem: VStreamItem, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        assertionFailure("VTrendingShelfCellFactory was provided a shelf that was neither a user shelf nor a hashtag shelf")
        return failureCellFactory.noContentCellForCollectionView(collectionView, atIndexPath: indexPath)
    }
    
    private func setup(cell: VTrendingShelfCollectionViewCell, shelf: Shelf, dependencyManager: VDependencyManager) {
        cell.dependencyManager = dependencyManager
        cell.shelf = shelf
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        return CGSize.zero
    }
    
    func minimumLineSpacing() -> CGFloat {
        return 7.0
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 11, 11, 11)
    }
    
}