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
        cell.user = user
        sharedQueue = RequestOperation().defaultQueue
    }

    override func tearDown() {
        super.tearDown()
        sharedQueue.cancelAllOperations()
    }

    func testFollowing() {
        user.isFollowedByMainUser = false
        let followControl = VFollowControl()

        cell.onFollow(followControl)
        guard let followOperation = notCancelledOperations.first as? FollowUsersOperation else {
            XCTFail("Follow users operation should be queued when following a user")
            return
        }
        XCTAssertEqual(VFollowSourceScreenDiscoverSuggestedUsers, followOperation.sourceScreenName)
    }

    func testUnfollowing() {
        user.isFollowedByMainUser = true
        let followControl = VFollowControl()

        cell.onFollow(followControl)
        guard let unfollowOperation = notCancelledOperations.first as? UnfollowUserOperation else {
            XCTFail("UnFollow users operation should be queued when unfollowing a user")
            return
        }
        XCTAssertEqual(VFollowSourceScreenDiscoverSuggestedUsers, unfollowOperation.sourceScreenName)
    }

    private var notCancelledOperations: [NSOperation] {
        return sharedQueue.operations.filter({ $0.cancelled != true })
    }
}
