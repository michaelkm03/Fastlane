//
//  ListMenuSectionDataSourceTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class TestListMenuSectionDataSourceDelegate: ListMenuSectionDataSourceDelegate {
    var didUpdateVisibleItemsCallCount: [ListMenuSection:Int] = [:]

    func didUpdateVisibleItems(forSection section: ListMenuSection) {
        if let existingCount = didUpdateVisibleItemsCallCount[section] {
            didUpdateVisibleItemsCallCount[section] = existingCount + 1
        }
        else {
            didUpdateVisibleItemsCallCount[section] = 1
        }
    }
}

class ListMenuSectionDataSourceTests: XCTestCase {
    func testFetchData() {
        let mockChatRooms = [ChatRoom(name: "Cupcakes")]
        let config = ["":""]
        let dependencyManager = VDependencyManager(dictionary: config)
        let dataSource = ListMenuSectionDataSource<ChatRoom, MockOperation<[ChatRoom]>>(
            dependencyManager: dependencyManager,
            cellConfiguration: { cell, item in
                cell.titleLabel.text = item.name
            },
            createOperation: { MockOperation(mockResult: .success(mockChatRooms)) },
            processOutput: { return $0 },
            section: .chatRooms
        )
        let testDelegate = TestListMenuSectionDataSourceDelegate()
        dataSource.delegate = testDelegate

        let expectation = expectationWithDescription("\(dataSource.dynamicType)) data fetch")
        dataSource.fetchData(
            success: { items in
                expectation.fulfill()
                XCTAssertEqual(1, testDelegate.didUpdateVisibleItemsCallCount[.chatRooms])
                XCTAssertEqual(dataSource.visibleItems.count, mockChatRooms.count)
            },
            failure: { error in
                XCTFail("fetchData failed where it should succeed")
            },
            cancelled: {
                XCTFail("fetchData was cancelled where it should succeed")
            }
        )

        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
