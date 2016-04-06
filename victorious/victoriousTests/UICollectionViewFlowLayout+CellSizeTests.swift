//
//  UICollectionViewFlowLayout+CellSizeTests.swift
//  victorious
//
//  Created by Jarod Long on 4/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class UICollectionViewFlowLayout_CellSizeTests: XCTestCase {
    
    func testCellSizeFittingWidth() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 1.0, left: 2.0, bottom: 3.0, right: 4.0)
        flowLayout.minimumInteritemSpacing = 10.0
        
        XCTAssertEqual(flowLayout.v_cellSize(fittingWidth: 200.0, cellsPerRow: 1), CGSize(width: 194.0, height: 194.0))
        XCTAssertEqual(flowLayout.v_cellSize(fittingWidth: 200.0, cellsPerRow: 2), CGSize(width:  92.0, height:  92.0))
        XCTAssertEqual(flowLayout.v_cellSize(fittingWidth: 200.0, cellsPerRow: 3), CGSize(width:  58.0, height:  58.0))
    }
}
