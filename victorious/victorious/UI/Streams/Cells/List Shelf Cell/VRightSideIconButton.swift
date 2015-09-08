//
//  VRightSideIconButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A UIButton with it's icon on the right side of the text instead of the left.
class VRightSideIconButton: UIButton {

    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        var frame = super.imageRectForContentRect(contentRect)
        frame.origin.x = contentRect.maxX - frame.width - imageEdgeInsets.right + imageEdgeInsets.left
        return frame
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        var frame = super.titleRectForContentRect(contentRect)
        frame.origin.x = contentRect.minX
        return frame
    }

}
