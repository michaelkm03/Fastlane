//
//  TouchableInsetAdjustableButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class TouchableInsetAdjustableButton: UIButton {
    var touchInsets = UIEdgeInsets.zero
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let touchableRect = UIEdgeInsetsInsetRect(bounds, touchInsets)
        return touchableRect.contains(point)
    }
}
