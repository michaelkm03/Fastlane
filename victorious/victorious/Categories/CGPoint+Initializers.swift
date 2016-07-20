//
//  CGPoint+Initializers.swift
//  victorious
//
//  Created by Jarod Long on 7/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    /// Initializes to a point on the edge of a circle of the given `radius` whose center lies at `origin`, determined
    /// by the given `angle` in radians.
    init(angle: CGFloat, onEdgeOfCircleWithRadius radius: CGFloat, origin: CGPoint = CGPoint.zero) {
        self.init(
            x: origin.x + radius * cos(angle),
            y: origin.y + radius * sin(angle)
        )
    }
}
