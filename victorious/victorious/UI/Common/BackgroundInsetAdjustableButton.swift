//
//  BackgroundInsetAdjustableButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class BackgroundInsetAdjustableButton: UIButton {
    
    var backgroundInsets = UIEdgeInsetsZero
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let touchableRect = UIEdgeInsetsInsetRect(bounds, backgroundInsets)
        return touchableRect.contains(point)
    }
}
