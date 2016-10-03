//
//  ListMenuCollectionViewDataSourceTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ListMenuCollectionViewDataSourceTests: XCTestCase {
    func testNoContentCell() {
        let dependencyManager = VDependencyManager(dictionary: [:])
        let listMenuViewController = ListMenuViewController.new(withDependencyManager:dependencyManager)
        listMenuViewController.beginAppearanceTransition(true, animated: false)
        let dataSource = ListMenuCollectionViewDataSource(dependencyManager: dependencyManager, listMenuViewController: listMenuViewController)
        let cell = dataSource.collectionView(listMenuViewController.collectionView, cellForItemAtIndexPath: IndexPath(forRow: 1, inSection: 1))
        XCTAssert(cell is ListMenuNoContentCollectionViewCell)
    }
}
