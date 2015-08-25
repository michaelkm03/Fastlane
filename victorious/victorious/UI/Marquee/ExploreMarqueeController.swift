//
//  ExploreMarqueeController.swift
//  victorious
//
//  Created by Tian Lan on 8/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ExploreMarqueeController: VInsetMarqueeController {
    override func desiredSizeWithCollectionViewBounds(bounds: CGRect) -> CGSize {
        let side = bounds.width
        return CGSizeMake(side, side/2)
    }
}
