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
}
