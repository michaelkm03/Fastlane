//
//  VStreamItemCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

let kShelfUnlikelyhood = 11

class VStreamItemCellFactory: NSObject, VStreamCellFactory, VHasManagedDependencies {
    
    private let sleekCellFactory : VSleekStreamCellFactory
    private let marqueeCellFactory : VMarqueeCellFactory
    
    required init(dependencyManager: VDependencyManager) {
        sleekCellFactory = VSleekStreamCellFactory(dependencyManager: dependencyManager)
        marqueeCellFactory = VMarqueeCellFactory(dependencyManager: dependencyManager)
    }
    
    func registerCellsWithCollectionView(collectionView: UICollectionView!) {
        sleekCellFactory.registerCellsWithCollectionView(collectionView)
        marqueeCellFactory.registerCellsWithCollectionView(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView!, cellForStreamItem streamItem: VStreamItem!, atIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        return factory(streamItem).collectionView(collectionView, cellForStreamItem: streamItem, atIndexPath: indexPath)
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem!) -> CGSize {
        return factory(streamItem).sizeWithCollectionViewBounds(bounds, ofCellForStreamItem: streamItem)
    }
    
    func minimumLineSpacing() -> CGFloat {
        return 1
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func factory(streamItem: VStreamItem) -> VStreamCellFactory {
        if ( streamItem.streamType == "shelf" )
        {
            return marqueeCellFactory
        }
        return sleekCellFactory
    }
}
