//
//  CGPoint+InitializersTests.swift
//  victorious
//
//  Created by Jarod Long on 7/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class CGPoint_InitializersTests: XCTestCase {
    func testPointOnCircle() {
        let pi = CGFloat(M_PI)
        
        assertPointsEqual(
            CGPoint(angle: 0.0, onEdgeOfCircleWithRadius: 1.0, origin: CGPoint.zero),
            CGPoint(x: 1.0, y: 0.0)
        )
        
        assertPointsEqual(
            CGPoint(angle: pi * 0.25, onEdgeOfCircleWithRadius: 1.0, origin: CGPoint.zero),
            CGPoint(x: 0.7071, y: 0.7071)
        )
        
        assertPointsEqual(
            CGPoint(angle: pi * 0.5, onEdgeOfCircleWithRadius: 1.0, origin: CGPoint.zero),
            CGPoint(x: 0.0, y: 1.0)
        )
        
        assertPointsEqual(
            CGPoint(angle: pi * 0.75, onEdgeOfCircleWithRadius: 2.0, origin: CGPoint.zero),
            CGPoint(x: -1.412, y: 1.412)
        )
        
        assertPointsEqual(
            CGPoint(angle: pi, onEdgeOfCircleWithRadius: 3.0, origin: CGPoint.zero),
            CGPoint(x: -3.0, y: 0.0)
        )
        
        assertPointsEqual(
            CGPoint(angle: pi * 1.25, onEdgeOfCircleWithRadius: 4.0, origin: CGPoint(x: 2.0, y: -4.0)),
            CGPoint(x: -0.8284, y: -6.8284)
        )
    }
    
    private func assertPointsEqual(a: CGPoint, _ b: CGPoint) {
        XCTAssertEqualWithAccuracy(a.x, b.x, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(a.y, b.y, accuracy: 0.001)
    }
}
