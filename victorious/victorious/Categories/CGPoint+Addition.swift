//
//  CGPoint+Addition.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/25/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

func +( lhs: CGPoint, rhs: CGPoint ) -> CGPoint {
    return CGPoint( x: lhs.x + rhs.x, y: lhs.y + rhs.y )
}
