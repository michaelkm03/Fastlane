//
//  ExploreMarqueeStreamItemCell.swift
//  victorious
//
//  Created by Tian Lan on 8/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc(ExploreMarqueeStreamItemCell)
class ExploreMarqueeStreamItemCell: VInsetMarqueeStreamItemCell {
    
    override class func desiredSizeWithCollectionViewBounds(bounds: CGRect) -> CGSize {
        let side = floor( bounds.width / ExploreMarqueeController.marqueeShelfAspectRatio )
        return CGSizeMake( side, side )
    }
    
    override var shouldSupportAutoplay: Bool {
        return false
    }
    
    override var onlyShowPreviewForTextPosts: Bool {
        return true
    }
}
