//
//  ExploreMarqueeCollectionViewCell.swift
//  victorious
//
//  Created by Tian Lan on 8/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc(ExploreMarqueeCollectionViewCell)
class ExploreMarqueeCollectionViewCell: VInsetMarqueeCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        marqueeCollectionView.registerNib(ExploreMarqueeStreamItemCell.nibForCell(), forCellWithReuseIdentifier: ExploreMarqueeStreamItemCell.suggestedReuseIdentifier())
    }
    
    override class func desiredSizeWithCollectionViewBounds(bounds: CGRect) -> CGSize {
        return ExploreMarqueeStreamItemCell.desiredSizeWithCollectionViewBounds(bounds)
    }
}
