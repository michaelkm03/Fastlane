//
//  CGRect+AspectTests.swift
//  victorious
//
//  Created by Michael Sena on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest

class CGRect_AspectTests: XCTestCase {

    let tallRect = CGRect(x: 0, y: 0, width: 32, height: 64)
    let wideRect = CGRect(x: 0, y: 0, width: 64, height: 32)
    let destRect = CGRect(x: 0, y: 0, width: 32, height: 32)
    
    func testAspectFitFunction() {
        let tallFitRect = tallRect.v_aspectFit(destRect)
        XCTAssertEqual(tallFitRect, CGRect(x: 8, y: 0, width: 16, height: 32))
        
        let wideFitRect = wideRect.v_aspectFit(destRect)
        XCTAssertEqual(wideFitRect, CGRect(x: 0, y: 8, width: 32, height: 16))
    }
    
    func testApectFillFunction() {
        let tallFillRect = tallRect.v_aspectFill(destRect)
        XCTAssertEqual(tallFillRect, CGRect(x: 0, y: -16, width: 32, height: 64))
        
        let wideFillRect = wideRect.v_aspectFill(destRect)
        XCTAssertEqual(wideFillRect, CGRect(x: -16, y: 0, width: 64, height: 32))
    }

}
