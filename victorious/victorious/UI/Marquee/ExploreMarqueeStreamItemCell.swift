//
//  ExploreMarqueeStreamItemCell.swift
//  victorious
//
//  Created by Tian Lan on 8/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc (ExploreMarqueeStreamItemCell)
class ExploreMarqueeStreamItemCell: VInsetMarqueeStreamItemCell {
    static let marqueeShelfAspectRatio: CGFloat = 1.6 // Per the design of 320:197 on iPhone 5
    
    override class func desiredSizeWithCollectionViewBounds(bounds: CGRect) -> CGSize {
        return CGSizeMake( bounds.width / marqueeShelfAspectRatio, bounds.width / marqueeShelfAspectRatio )
    }
    
    override var shouldSupportAutoplay: Bool {
        return false
    }
}
