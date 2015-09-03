//
//  ExploreMarqueeController.swift
//  victorious
//
//  Created by Tian Lan on 8/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ExploreMarqueeController: VInsetMarqueeController {

    override func registerCollectionViewCellWithCollectionView(collectionView: UICollectionView) {
        collectionView.registerNib(ExploreMarqueeCollectionViewCell.nibForCell(), forCellWithReuseIdentifier: ExploreMarqueeCollectionViewCell.suggestedReuseIdentifier())
    }
    
    override func marqueeCellForCollectionView(collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath) -> VAbstractMarqueeCollectionViewCell {
        if let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(ExploreMarqueeCollectionViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as? ExploreMarqueeCollectionViewCell {
            if collectionViewCell.marquee != self {
                collectionViewCell.marquee = self
                collectionViewCell.dependencyManager = self.dependencyManager
                self.enableTimer()
            }
            return collectionViewCell
        }
        fatalError("Failed to dequeue a marquee collection view cell!")
    }
    
    override func desiredSizeWithCollectionViewBounds(bounds: CGRect) -> CGSize {
        return ExploreMarqueeCollectionViewCell.desiredSizeWithCollectionViewBounds(bounds)
    }
    
    override class func marqueeStreamItemCellClass() -> AnyObject.Type {
        return ExploreMarqueeStreamItemCell.self
    }
    
    // This is responsible for the cell size of the marquee collection view
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return ExploreMarqueeStreamItemCell.desiredSizeWithCollectionViewBounds(collectionView.bounds)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let streamItemCellWidth = ExploreMarqueeStreamItemCell.desiredSizeWithCollectionViewBounds(collectionView.bounds).width
        let sideInset = (collectionView.bounds.width - streamItemCellWidth) / 2
        return UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
}
