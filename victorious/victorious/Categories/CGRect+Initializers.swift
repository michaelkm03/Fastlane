//
//  CGRect+Initializers.swift
//  victorious
//
//  Created by Jarod Long on 6/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(
            origin: CGPoint(
                x: center.x - size.width / 2.0,
                y: center.y - size.height / 2.0
            ),
            size: size
        )
    }
}
