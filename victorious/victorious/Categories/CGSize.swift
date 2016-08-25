//
//  CGSize+CornerRadius.swift
//  victorious
//
//  Created by Jarod Long on 3/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension CGSize {
    
    // MARK: - Positioning
    
    func centered(on point: CGPoint) -> CGRect {
        return CGRect(
            origin: CGPoint(x: point.x - width / 2.0, y: point.y - height / 2.0),
            size: self
        )
    }
    
    // MARK: - Geometric properties
    
    /// Returns a corner radius that can be applied to a rectangle of this size to give it the maximal amount of roundness.
    var v_roundCornerRadius: CGFloat {
        return min(width, height) / 2.0
    }
}
