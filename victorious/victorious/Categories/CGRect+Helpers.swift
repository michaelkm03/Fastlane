//
//  CGRect+Helpers.swift
//  victorious
//
//  Created by Vincent Ho on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(
            x: midX,
            y: midY
        )
    }
    
    func insetBy(insets: UIEdgeInsets) -> CGRect {
        var rect = self
        rect.origin.x += insets.left
        rect.origin.y += insets.top
        rect.size.width -= insets.horizontal
        rect.size.height -= insets.vertical
        return rect
    }
}
