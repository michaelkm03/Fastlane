//
//  RepostersDataSourceTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class TestRepostersDataSource: RepostersDataSource {
    let testVisibleItems: [VUser]

    init(sequence: VSequence,
        dependencyManager: VDependencyManager,
        sourceScreenName: String, visibleItems: [VUser]) {

            testVisibleItems = visibleItems
            super.init(sequence: sequence, dependencyManager: dependencyManager, sourceScreenName: sourceScreenName)
    }

    override var visibleItems: NSOrderedSet {
        return NSOrderedSet(array: testVisibleItems)
    }
}

class RepostersDataSourceTests: BasePersistentStoreTestCase {
    var dataSource: TestRepostersDataSource!
    var dependencyManager: VDependencyManager!
    var users: [VUser]!

    override func setUp() {
        super.setUp()
        let sequence = persistentStoreHelper.createSequence(remoteId: 1)
        dependencyManager = VDependencyManager(parentManager: nil, configuration: nil, dictionaryOfClassesByTemplateName: nil)
        users = [persistentStoreHelper.createUser(remoteId: 1)]
        dataSource = TestRepostersDataSource(sequence: sequence,
            dependencyManager: dependencyManager,
            sourceScreenName: VFollowSourceScreenReposter,
            visibleItems: users)
    }

    func testCellSetup() {
        let tableView = UITableView()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        dataSource.registerCells(tableView)
        let tableCell = dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
        guard let typedCell = tableCell as? VInviteFriendTableViewCell else {
            XCTFail("A cell provided by RepostersDataSource is not VInviteFriendTableViewCell")
            return
        }
        XCTAssertEqual(VFollowSourceScreenReposter, typedCell.sourceScreenName)
        XCTAssertEqual(dependencyManager, typedCell.dependencyManager)
    }
}
