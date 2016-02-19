//
//  VInviteFriendTableViewCellTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VInviteFriendTableViewCellTests: BasePersistentStoreTestCase {
    var cell: VInviteFriendTableViewCell!
    var user: VUser!
    var sharedQueue: NSOperationQueue!

    override func setUp() {
        super.setUp()
        cell = VInviteFriendTableViewCell()
        cell.sourceScreenName = VFollowSourceScreenReposter
        user = persistentStoreHelper.createUser(remoteId: 1)
        cell.profile = user
        sharedQueue = RequestOperation().defaultQueue
    }

    override func tearDown() {
        super.tearDown()
        sharedQueue.cancelAllOperations()
    }

    func testFollowing() {
        user.isFollowedByMainUser = false
        let followControl = VFollowControl()

        cell.followUnfollowUser(followControl)
        guard let followOperation = sharedQueue.operations.filter({ $0.cancelled != true }).first as? FollowUsersOperation else {
            XCTFail("Follow users operation should be queued when following a user")
            return
        }
        XCTAssertEqual(VFollowSourceScreenReposter, followOperation.sourceScreenName)
    }

    func testUnfollowing() {
        user.isFollowedByMainUser = true
        let followControl = VFollowControl()

        cell.followUnfollowUser(followControl)
        guard let unfollowOperation = sharedQueue.operations.filter({ $0.cancelled != true }).first as? UnfollowUserOperation else {
            XCTFail("UnFollow users operation should be queued when unfollowing a user")
            return
        }
        XCTAssertEqual(VFollowSourceScreenReposter, unfollowOperation.sourceScreenName)
    }
}
