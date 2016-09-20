//
//  ListMenuChatRoomsDataSourceTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ListMenuChatRoomsDataSourceTests: XCTestCase {
    func testFetchRemoteData() {
        let mockChatRooms = [ChatRoom(name: "Cupcakes")]
        let requestExecutor = TestRequestExecutor(result: mockChatRooms)
        let config = ["networkResources":["chat.rooms.URL":"http://example.com"]]
        let dependencyManager = VDependencyManager(parentManager: nil, configuration: config, dictionaryOfClassesByTemplateName: [:])
        let dataSource = ListMenuChatRoomsDataSource(dependencyManager: dependencyManager)
        dataSource.requestExecutor = requestExecutor
        let expectation = expectationWithDescription("ListMenuChatRoomsDataSource data fetch")
        dataSource.onFetchDataSuccess = {
            expectation.fulfill()
            XCTAssertEqual(dataSource.visibleItems.count, mockChatRooms.count)
        }

        dataSource.fetchRemoteData()
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
