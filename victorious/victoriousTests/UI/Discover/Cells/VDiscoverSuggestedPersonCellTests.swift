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
        sharedQueue = FetcherOperation().defaultQueue
    }

    override func tearDown() {
        super.tearDown()
        sharedQueue.cancelAllOperations()
    }

    func testFollowing() {
        let followControl = VFollowControl()
        var operationsInQueue = [NSOperation]()

        cell.onFollow(followControl)
        
        operationsInQueue = sharedQueue.operations.filter { !$0.cancelled && $0 is ToggleFollowUserOperation }
        guard let toggleOperation = operationsInQueue.first as? ToggleFollowUserOperation else {
            XCTFail("ToggleFollowUserOperation should be queued when following a user")
            return
        }
        toggleOperation.main()
        
        operationsInQueue = sharedQueue.operations.filter { !$0.cancelled && $0 is FollowUsersOperation }
        guard let followOperation = operationsInQueue.first as? FollowUsersOperation else {
            XCTFail("FollowUsersOperation should be queued after ToggleFollowUserOperation")
            return
        }
        XCTAssertEqual(VFollowSourceScreenDiscoverSuggestedUsers, followOperation.sourceScreenName)
    }

    func testUnfollowing() {
        FollowUsersOperation(userID: 1, sourceScreenName: "").main()
        
        let followControl = VFollowControl()
        var operationsInQueue = [NSOperation]()
        
        cell.onFollow(followControl)
        
        operationsInQueue = sharedQueue.operations.filter { !$0.cancelled && $0 is ToggleFollowUserOperation }
        guard let toggleOperation = operationsInQueue.first as? ToggleFollowUserOperation else {
            XCTFail("ToggleFollowUserOperation should be queued when unfollowing a user")
            return
        }
        
        toggleOperation.main()
        operationsInQueue = sharedQueue.operations.filter { !$0.cancelled && $0 is UnfollowUserOperation }
        guard let unFollowOperation = operationsInQueue.first as? UnfollowUserOperation else {
            XCTFail("UnfollowUserOperation should be queued after ToggleFollowUserOperation")
            return
        }
        XCTAssertEqual(VFollowSourceScreenDiscoverSuggestedUsers, unFollowOperation.sourceScreenName)
    }
}
