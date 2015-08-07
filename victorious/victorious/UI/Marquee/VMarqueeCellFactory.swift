//
//  VMarqueeCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/**
    A wrapper around the marquee controller that adds conformance to the VStreamCellFactory protocol.
*/
class VMarqueeCellFactory: NSObject, VHasManagedDependencies {
    
    //The controller responsible for managing the display, reuse, and data updating for a marquee.
    let marqueeController : VMarqueeController?

    required init(dependencyManager: VDependencyManager) {
        let templateValue: AnyObject! = dependencyManager.templateValueConformingToProtocol(VMarqueeController.self, forKey: "marqueeCell")
        if let marquee = templateValue as? VMarqueeController {
            marqueeController = marquee
        } else {
            marqueeController = nil
        }
    }
   
}

extension VMarqueeCellFactory : VStreamCellFactory {
    
    func registerCellsWithCollectionView(collectionView: UICollectionView) {
        marqueeController?.registerCollectionViewCellWithCollectionView(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, cellForStreamItem streamItem: VStreamItem, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let controller = marqueeController {
            if let shelf = streamItem as? VShelf {
                controller.setShelf(shelf)
            }
            return controller.marqueeCellForCollectionView(collectionView, atIndexPath:indexPath)
        }
        assertionFailure("A marquee cell was requested from a factory with a nil marquee controller. Check marqueeCell in template response.")
        return UICollectionViewCell.new()
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem) -> CGSize {
        if let marquee = marqueeController {
            return marquee.desiredSizeWithCollectionViewBounds(bounds)
        }
        return CGSizeZero
    }
    
    func minimumLineSpacing() -> CGFloat {
        return 1
    }
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
}