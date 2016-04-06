//
//  CGSize+CornerRadius.swift
//  victorious
//
//  Created by Jarod Long on 3/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension CGSize {
    
    /// Returns a corner radius that can be applied to a rectangle of this size to give it the maximal amount of roundness.
    var v_roundCornerRadius: CGFloat {
        return min(width, height) / 2.0
    }
    
}
