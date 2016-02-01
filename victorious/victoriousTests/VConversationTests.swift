//
//  VConversationTests.swift
//  victorious
//
//  Created by Michael Sena on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VConversationTests: BasePersistentStoreTestCase {

    var conversation: VConversation!
    
    override func setUp() {
        super.setUp()
        conversation = persistentStoreHelper.createConversation()
    }
    
    func testMarkedForDeletionPredicates() {
        let markedForDeletionPredicate = VConversation.markedForDeletionPredicate
        self.conversation.markedForDeletion = true
        XCTAssertTrue(markedForDeletionPredicate.evaluateWithObject(self.conversation))

        let notMarkedForDeletionPredicate = VConversation.notMarkedForDeletionPredicate
        self.conversation.markedForDeletion = false
        XCTAssertTrue(notMarkedForDeletionPredicate.evaluateWithObject(self.conversation))
    }
}
