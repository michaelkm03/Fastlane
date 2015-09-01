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
    }
    
    override class func desiredSizeWithCollectionViewBounds(bounds: CGRect) -> CGSize {
        return CGSizeMake(bounds.width, bounds.width / 2)
    }
}

extension ExploreMarqueeCollectionViewCell: VBackgroundContainer {
    func backgroundContainerView() -> UIView! {
        return contentView
    }
}
