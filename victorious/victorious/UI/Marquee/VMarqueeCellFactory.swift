//
//  VMarqueeCellFactory.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VMarqueeCellFactory: NSObject, VStreamCellFactory, VHasManagedDependencies {
    
    private let marqueeController : VMarqueeController?

    required init(dependencyManager: VDependencyManager) {
        let templateValue: AnyObject! = dependencyManager.templateValueOfType(VAbstractMarqueeController.self, forKey: "marqueeCell")
        if let marquee = templateValue as? VMarqueeController {
            marqueeController = marquee
        }
        else {
            marqueeController = nil
        }
    }
   
    func registerCellsWithCollectionView(collectionView: UICollectionView!) {
        marqueeController?.registerCollectionViewCellWithCollectionView(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView!, cellForStreamItem streamItem: VStreamItem!, atIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        if let shelf = streamItem as? VShelf {
            marqueeController?.setShelf(shelf)
        }
        return marqueeController?.marqueeCellForCollectionView(collectionView, atIndexPath:indexPath)
    }
    
    func sizeWithCollectionViewBounds(bounds: CGRect, ofCellForStreamItem streamItem: VStreamItem!) -> CGSize {
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
