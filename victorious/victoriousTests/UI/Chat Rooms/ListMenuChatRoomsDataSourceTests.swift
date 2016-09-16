//
//  ListMenuChatRoomsDataSourceTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import victorious

class ListMenuChatRoomsDataSourceTests: XCTestCase {
    func testFetchRemoteData() {
        let mockChatRooms = [ChatRoom(name: "Cupcakes")]
        let requestExecutor = TestRequestExecutor(result: mockChatRooms)
        let dependencyManager = VDependencyManager(parentManager: nil, configuration: [:], dictionaryOfClassesByTemplateName: [:])
        let dataSource = ListMenuChatRoomsDataSource(dependencyManager: dependencyManager, requestExecutor: requestExecutor)
        XCTAssertEqual(dataSource.visibleItems, mockChatRooms)
    }
}
