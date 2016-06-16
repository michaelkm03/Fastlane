//
//  VDiscoverSuggestedPersonCellTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VDiscoverSuggestedPersonCellTests: BasePersistentStoreTestCase {
    var cell: VDiscoverSuggestedPersonCell!
    var user: VUser!
    var sharedQueue: NSOperationQueue!

    override func setUp() {
        super.setUp()
        cell = VDiscoverSuggestedPersonCell()
        user = persistentStoreHelper.createUser(remoteId: 1)
        persistentStoreHelper.createUser(remoteId: 2).setAsCurrentUser()
        cell.user = user
        sharedQueue = FetcherOperation().v_defaultQueue
    }

    override func tearDown() {
        super.tearDown()
        sharedQueue.cancelAllOperations()
    }

    func testFollowing() {
        // FollowUserOperation/FollowUserToggleOperation not supported in 5.0
    }

    func testUnfollowing() {
        // FollowUserOperation/FollowUserToggleOperation not supported in 5.0
    }
}
