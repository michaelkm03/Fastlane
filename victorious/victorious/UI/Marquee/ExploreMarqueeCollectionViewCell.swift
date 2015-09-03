//
//  ExploreMarqueeCollectionViewCell.swift
//  victorious
//
//  Created by Tian Lan on 8/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc(ExploreMarqueeCollectionViewCell)
class ExploreMarqueeCollectionViewCell: VInsetMarqueeCollectionViewCell, VBackgroundContainer {
    
    static let marqueeShelfAspectRatio: CGFloat = 1.6 // Per the design of 320:197 on iPhone 5

    override var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                dependencyManager.addBackgroundToBackgroundHost(self)
            }
        }
    }
    
    override func awakeFromNib() {
        marqueeCollectionView.registerNib(ExploreMarqueeStreamItemCell.nibForCell(), forCellWithReuseIdentifier: ExploreMarqueeStreamItemCell.suggestedReuseIdentifier())
        let flowLayout = VExploreMarqueeCollectionViewFlowLayout()
        marqueeCollectionView.collectionViewLayout = flowLayout
        marqueeCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override class func desiredSizeWithCollectionViewBounds(bounds: CGRect) -> CGSize {
        return CGSizeMake(bounds.width, bounds.width / marqueeShelfAspectRatio)
    }
}

extension ExploreMarqueeCollectionViewCell: VBackgroundContainer {
    func backgroundContainerView() -> UIView {
        return contentView
    }
}
