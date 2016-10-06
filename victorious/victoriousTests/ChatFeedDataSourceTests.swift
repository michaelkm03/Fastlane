//
//  ChatFeedDataSourceTests.swift
//  victorious
//
//  Created by Jarod Long on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class ChatFeedDataSourceTests: XCTestCase, ForumEventReceiver {
    let dataSource = ChatFeedDataSource(dependencyManager: VDependencyManager(dictionary: [:]))
    
    var childEventReceivers: [ForumEventReceiver] {
        return [dataSource]
    }
    
    func testShowReplyButtons() {
        XCTAssert(dataSource.shouldShowReplyButtons)
        
        broadcast(.filterContent(path: APIPath(templatePath:"foo")))
        XCTAssertFalse(dataSource.shouldShowReplyButtons)
        
        broadcast(.filterContent(path: nil))
        XCTAssert(dataSource.shouldShowReplyButtons)
    }
}
