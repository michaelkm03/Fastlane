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
    func testAvailableSections() {
        let dependencyManager = VDependencyManager(dictionary: [:])
        let listMenuViewController = ListMenuViewController.newWithDependencyManager(dependencyManager)
        listMenuViewController.beginAppearanceTransition(true, animated: false)
        let dataSource = ListMenuCollectionViewDataSource(dependencyManager: dependencyManager, listMenuViewController: listMenuViewController)
        XCTAssert(dataSource.availableSections.isEmpty)
    }
}
