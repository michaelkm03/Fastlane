//
//  VUserProfileViewControllerTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VUserProfileViewControllerTests: BasePersistentStoreTestCase {
    var controller: VUserProfileViewController!
    var user: VUser!
    var sharedQueue: NSOperationQueue!

    override func setUp() {
        super.setUp()
        let dependencyManager = VDependencyManager(parentManager: nil, configuration: nil, dictionaryOfClassesByTemplateName: nil)
        controller = VUserProfileViewController.newWithDependencyManager(dependencyManager)
        user = persistentStoreHelper.createUser(remoteId: 1)
        controller.user = user
        sharedQueue = RequestOperation().defaultQueue
    }

    override func tearDown() {
        super.tearDown()
        sharedQueue?.cancelAllOperations()
    }

    func testFollowing() {
        user.isFollowedByMainUser = false
        controller.toggleFollowUser()
        let followOperations = sharedQueue.operations.filter({ $0.cancelled != true && $0 is FollowUsersOperation })
        XCTAssertEqual(1, followOperations.count)
        guard let followOperation = followOperations.first as? FollowUsersOperation else {
            XCTFail("Follow users operation should be queued when following a user")
            return
        }
        XCTAssertEqual(VFollowSourceScreenProfile, followOperation.sourceScreenName)
    }

    func testUnfollowing() {
        user.isFollowedByMainUser = true
        controller.toggleFollowUser()
        let unFollowOperations = sharedQueue.operations.filter({ $0.cancelled != true && $0 is UnfollowUserOperation })
        XCTAssertEqual(1, unFollowOperations.count)
        guard let unfollowOperation = unFollowOperations.first as? UnfollowUserOperation else {
            XCTFail("UnFollow users operation should be queued when unfollowing a user")
            return
        }
        XCTAssertEqual(VFollowSourceScreenProfile, unfollowOperation.sourceScreenName)
    }
}
